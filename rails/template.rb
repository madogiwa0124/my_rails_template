# frozen_string_literal: true

def source_paths
  [__dir__]
end

gem 'okcomputer'
gem 'redis'
gem 'sidekiq'
gem 'simpacker'

gem_group :development, :test do
  gem 'bullet'
  gem 'brakeman', require: false
  gem 'erb_lint', require: false
  gem 'rspec-rails', require: false
  gem 'factory_bot_rails'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

initializer 'ok_computer.rb', <<~CODE
  OkComputer::Registry.register 'ruby version', OkComputer::RubyVersionCheck.new
  # OkComputer::Registry.register 'version', OkComputer::AppVersionCheck.new(env: 'SOURCE_VERSION')
CODE

initializer 'lograge.rb', <<~CODE
  Rails.application.configure do
    config.lograge.enabled = true
initializer 'sidekiq.rb', <<~CODE
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV['REDIS_URL'] }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDIS_URL'] }
  end
CODE

environment <<~TEXT
  # For TZ
  config.time_zone = 'Tokyo'
  # config.active_record.default_timezone = :local

  # For custom settings
  config.settings = config_for(:settings)

  # For generator
  config.generators do |g|
    g.assets false
    g.helper false
    g.test_framework :rspec,
      fixtures:         true,
      view_specs:       false,
      helper_specs:     false,
      routing_specs:    false,
      controller_specs: false,
      request_specs:    false
    g.fixture_replacement :factory_bot, dir: 'spec/factories'
    g.after_generate do |files|
      system('bundle exec rubocop --auto-correct-all ' + files.join(' '), exception: true)
    end
  end

  # For ActiveJob and ActionMailer
  config.active_job.queue_adapter = :sidekiq
  config.active_job.default_queue_name = :default
  config.action_mailer.deliver_later_queue_name = :default
TEXT

development_setting = <<~CODE
  # For docker environment
  # In the Dcoker environment, the host directory is mounted on the virtual environment as a shared file using volume,
  # and this method does not generate any change events.
  config.file_watcher = ActiveSupport::FileUpdateChecker

  # For Bullet
  config.after_initialize do
    Bullet.enable = true
    Bullet.rails_logger = true
  end
CODE

test_setting = <<~CODE
  # For Bullet
  config.after_initialize do
    Bullet.enable = true
    Bullet.rails_logger = true
    Bullet.raise = true
  end
CODE

environment development_setting, env: 'development'
environment test_setting, env: 'test'

route <<~CODE
  # For Sidekiq Web UI
  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq'
CODE

copy_file '.rubocop.yml', '.rubocop.yml'
copy_file '.erb-lint.yml', '.erb-lint.yml'
copy_file '.editorconfig', '.editorconfig'
copy_file 'config/sidekiq.yml', 'config/sidekiq.yml'
copy_file 'config/simpacker.yml', 'config/simpacker.yml'
copy_file 'config/settings.yml', 'config/settings.yml'

run "cp .gitignore .dockerignore"
