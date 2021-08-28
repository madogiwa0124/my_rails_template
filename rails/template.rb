# frozen_string_literal: true

def source_paths
  [__dir__]
end

gem 'okcomputer'
gem 'lograge'
gem 'simpacker'

gem_group :development, :test do
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
    config.lograge.custom_options = ->(event) { { time: Time.current } }
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
TEXT

copy_file '.rubocop.yml', '.rubocop.yml'
copy_file '.erb-lint.yml', '.erb-lint.yml'
copy_file '.editorconfig', '.editorconfig'
copy_file 'config/simpacker.yml', 'config/simpacker.yml'
copy_file 'config/settings.yml', 'config/settings.yml'

run "cp .gitignore .dockerignore"
