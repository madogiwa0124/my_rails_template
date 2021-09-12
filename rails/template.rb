# frozen_string_literal: true
require 'erb'

def source_paths
  [__dir__]
end

gem 'okcomputer'
gem 'lograge'
gem 'redis'
gem 'sidekiq'
gem 'simpacker'
gem 'rails-i18n', '~> 6.0.0'

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

gem_group :development do
  gem 'letter_opener_web', '~> 1.0'
end

gem_group :test do
  gem 'capybara'
  gem 'simplecov', require: false
end

initializer 'okcomputer.rb', <<~CODE
  OkComputer::Registry.register 'ruby version', OkComputer::RubyVersionCheck.new
  # OkComputer::Registry.register 'version', OkComputer::AppVersionCheck.new(env: 'SOURCE_VERSION')
  # OkComputer::Registry.register 'redis', OkComputer::RedisCheck.new({})
  # OkComputer::Registry.register 'ruby version', OkComputer::RubyVersionCheck.new
  # OkComputer::Registry.register 'cache', OkComputer::GenericCacheCheck.new
  # OkComputer::Registry.register 'sidekiq latency', OkComputer::SidekiqLatencyCheck.new('default')
CODE

initializer 'lograge.rb', <<~CODE
  Rails.application.configure do
    config.lograge.enabled = true
    # NOTE: ignored `/healthcheck `
    config.lograge.ignore_actions = ['OkComputer::OkComputerController#show']
    config.lograge.custom_payload do |controller|
      {
        host: controller.request.host,
        request_id: controller.request.request_id,
        remote_ip: controller.request.remote_ip,
        user_agent: controller.request.user_agent,
      }
    end
    config.lograge.custom_options = lambda do |event|
      {
        host: event.payload[:host],
        request_id: event.payload[:request_id],
        remote_ip: event.payload[:remote_ip],
        user_agent: event.payload[:user_agent],
        time: Time.current.iso8601
      }
    end
  end
CODE

initializer 'sidekiq.rb', <<~CODE
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV['REDIS_URL'] }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDIS_URL'] }
  end
CODE

environment <<~'CODE'
  # For TZ
  config.time_zone = 'Tokyo'
  # config.active_record.default_timezone = :local

  # For I18n
  config.i18n.available_locales = [:ja, :en]
  config.i18n.default_locale = :ja
  config.i18n.fallbacks = [:ja, :en]

  # For MultiDB
  config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session

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

  # For default error tag
  config.action_view.field_error_proc = proc do |html_tag, instance|
    if instance.is_a?(ActionView::Helpers::Tags::Label)
      html_tag
    else
      %(<div class="field_with_errors">#{html_tag}</div>).html_safe # rubocop:disable Rails/OutputSafety
    end
  end

  # For ActiveJob and ActionMailer
  config.active_job.log_arguments = false
  config.active_job.queue_adapter = :sidekiq
  config.active_job.default_queue_name = :default
  config.action_mailer.deliver_later_queue_name = :default
CODE

development_setting = <<~'CODE'
  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
    config.session_store :cache_store
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # For docker environment
  # In the Dcoker environment, the host directory is mounted on the virtual environment as a shared file using volume,
  # and this method does not generate any change events.
  config.file_watcher = ActiveSupport::FileUpdateChecker

  # For local Mailer
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # For Bullet
  config.after_initialize do
    Bullet.enable = true
    Bullet.rails_logger = true
  end
CODE

test_setting = <<~CODE
  # For local Mailer
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # For Bullet
  config.after_initialize do
    Bullet.enable = true
    Bullet.rails_logger = true
    Bullet.raise = true
  end
CODE

production_setting = <<~CODE
  # For cache and session used by default same redis.
  config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
  config.session_store(:cache_store, secure: true, after: 30.days)
CODE

environment development_setting, env: 'development'
environment test_setting, env: 'test'
environment production_setting, env: 'production'

route <<~CODE
  For LetterOpenerWeb
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # For Sidekiq Web UI
  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq'
CODE

db_config_template_path = (source_paths + ["config/database.yml.erb"]).join("/")
db_config_output_path   = (source_paths + ["config/tmp/database.yml"]).join("/")
File.open(db_config_output_path, "w") do |f|
  result = ERB.new(File.read(db_config_template_path)).result(binding)
  f.write(result)
end

copy_file '.rubocop.yml', '.rubocop.yml'
copy_file '.erb-lint.yml', '.erb-lint.yml'
copy_file '.editorconfig', '.editorconfig'
copy_file 'config/sidekiq.yml', 'config/sidekiq.yml'
copy_file 'config/simpacker.yml', 'config/simpacker.yml'
copy_file 'config/settings.yml', 'config/settings.yml'
copy_file 'config/tmp/database.yml', 'config/database.yml'
copy_file 'app/models/application_record.rb', 'app/models/application_record.rb'

run "cp .gitignore .dockerignore"
