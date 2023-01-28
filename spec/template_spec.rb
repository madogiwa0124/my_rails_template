RSpec.describe 'MyRailsTemplate' do
  describe 'Rails new' do
    let!(:app_name) { "test_app" }
    let!(:app_path) { "spec/tmp/#{app_name}" }
    let!(:template_path) { "./rails/template.rb" }

    before { system "XDG_CONFIG_HOME=./ bundle exec rails new #{app_path} -m #{template_path}" }
    after { system "rm -rf #{app_path}" }

    it 'executed by using template and railsrc.' do
      file_path = ->(path) { File.join(app_path, path) }

      # check generated files
      expect(File.exist?(app_path)).to eq true
      expect(File.exist?(file_path.call('config/initializers/okcomputer.rb'))).to eq true
      expect(File.exist?(file_path.call('config/initializers/sidekiq.rb'))).to eq true
      expect(File.exist?(file_path.call('config/initializers/lograge.rb'))).to eq true
      expect(File.exist?(file_path.call('config/settings.yml'))).to eq true
      expect(File.exist?(file_path.call('config/sidekiq.yml'))).to eq true
      expect(File.exist?(file_path.call('config/simpacker.yml'))).to eq true
      expect(File.exist?(file_path.call('.rubocop.yml'))).to eq true
      expect(File.exist?(file_path.call('.erb-lint.yml'))).to eq true
      expect(File.exist?(file_path.call('.editorconfig'))).to eq true
      expect(File.exist?(file_path.call('.dockerignore'))).to eq true

      # checked added gems
      gem_file_text = File.read(file_path.call('Gemfile'))
      expect(gem_file_text.include?("lograge")).to eq true
      expect(gem_file_text.include?("okcomputer")).to eq true
      expect(gem_file_text.include?("sidekiq")).to eq true
      expect(gem_file_text.include?("redis")).to eq true
      expect(gem_file_text.include?("simpacker")).to eq true
      expect(gem_file_text.include?("rubocop")).to eq true
      expect(gem_file_text.include?("erb_lint")).to eq true
      expect(gem_file_text.include?("rspec-rails")).to eq true
      expect(gem_file_text.include?("capybara")).to eq true
      expect(gem_file_text.include?("simplecov")).to eq true
      expect(gem_file_text.include?("letter_opener_web")).to eq true
      expect(gem_file_text.include?("sendgrid-actionmailer")).to eq true

      # checked application.rb
      application_file_text = File.read(file_path.call('config/application.rb'))
      expect(application_file_text.include?("config.time_zone = 'Tokyo'")).to eq true
      expect(application_file_text.include?("config.settings = config_for(:settings)")).to eq true
      expect(application_file_text.include?("config.i18n.available_locales = [:ja, :en]")).to eq true
      expect(application_file_text.include?("config.i18n.default_locale = :ja")).to eq true
      expect(application_file_text.include?("config.i18n.fallbacks = [:ja, :en]")).to eq true
      expect(application_file_text.include?("config.generators do |g|")).to eq true
      expect(application_file_text.include?("config.active_record.database_selector")).to eq true
      expect(application_file_text.include?("config.active_record.database_resolver")).to eq true
      expect(application_file_text.include?("config.active_record.database_resolver_context")).to eq true
      expect(application_file_text.include?("config.active_job.log_arguments = false")).to eq true
      expect(application_file_text.include?("config.active_job.queue_adapter = :sidekiq")).to eq true
      expect(application_file_text.include?("config.active_job.default_queue_name = :default")).to eq true
      expect(application_file_text.include?("config.action_mailer.deliver_later_queue_name = :default")).to eq true
      expect(application_file_text.include?("config.action_view.field_error_proc = proc")).to eq true
      expect(application_file_text.include?("config.active_record.query_log_tags_enabled = true")).to eq true

      #checked production
      production_file_text = File.read(file_path.call('config/environments/production.rb'))
      expect(production_file_text.include?("config.cache_store = :redis_cache_store")).to eq true
      expect(production_file_text.include?("config.session_store(:cache_store, secure: true")).to eq true
      expect(production_file_text.include?("config.action_mailer.sendgrid_actionmailer_settings = { api_key: ENV['SENDGRID_API_KEY'] }")).to eq true
      expect(production_file_text.include?("config.action_mailer.default_url_options = { host: 'yourhost.example.com', protocol: :https }")).to eq true

      # checked development
      development_file_text = File.read(file_path.call('config/environments/development.rb'))
      expect(development_file_text.include?("Bullet.enable")).to eq true
      expect(development_file_text.include?("config.action_mailer.delivery_method")).to eq true
      expect(development_file_text.include?("config.action_mailer.default_url_options")).to eq true
      expect(development_file_text.include?("config.cache_store = :redis_cache_store")).to eq true
      expect(development_file_text.include?("config.session_store :cache_store")).to eq true
      expect(development_file_text.include?("config.action_view.annotate_rendered_view_with_filenames = true")).to eq true

      # checked test
      test_file_text = File.read(file_path.call('config/environments/test.rb'))
      expect(test_file_text.include?("Bullet.enable")).to eq true
      expect(development_file_text.include?("config.action_mailer.default_url_options")).to eq true

      # checked routes
      routes_file_text = File.read(file_path.call('config/routes.rb'))
      expect(routes_file_text.include?("require 'sidekiq/web'")).to eq true
      expect(routes_file_text.include?("mount Sidekiq::Web, at: '/sidekiq'")).to eq true
      expect(routes_file_text.include?("mount LetterOpenerWeb::Engine, at: '/letter_opener'")).to eq true

      # checked database
      database_file_text = File.read(file_path.call('config/database.yml'))
      expect(database_file_text.include?("primary")).to eq true
      expect(database_file_text.include?("primary_replica")).to eq true
      expect(database_file_text.include?("url: <%= ENV['DATABASE_URL'] %>")).to eq true
      expect(database_file_text.include?("database: #{app_name}_development")).to eq true
      expect(database_file_text.include?("database: #{app_name}_test")).to eq true
      expect(database_file_text.include?("database: #{app_name}_production")).to eq true
    end
  end
end
