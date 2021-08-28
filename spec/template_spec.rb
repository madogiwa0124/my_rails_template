RSpec.describe 'MyRailsTemplate' do
  describe 'Rails new' do
    let!(:app_path) { "spec/tmp/test_app" }
    let!(:template_path) { "./rails/template.rb" }

    before { system "XDG_CONFIG_HOME=./ bundle exec rails new #{app_path} -m #{template_path}" }
    after { system "rm -rf #{app_path}" }

    it 'executed by using template and railsrc.' do
      file_path = ->(path) { File.join(app_path, path) }

      # check generated files
      expect(File.exist?(app_path)).to eq true
      expect(File.exist?(file_path.call('config/initializers/ok_computer.rb'))).to eq true
      expect(File.exist?(file_path.call('config/initializers/lograge.rb'))).to eq true
      expect(File.exist?(file_path.call('config/settings.yml'))).to eq true
      expect(File.exist?(file_path.call('config/simpacker.yml'))).to eq true
      expect(File.exist?(file_path.call('.rubocop.yml'))).to eq true
      expect(File.exist?(file_path.call('.erb-lint.yml'))).to eq true
      expect(File.exist?(file_path.call('.editorconfig'))).to eq true
      expect(File.exist?(file_path.call('.dockerignore'))).to eq true

      # checked added gems
      gem_file_text = File.read(file_path.call('Gemfile'))
      expect(gem_file_text.include?("lograge")).to eq true
      expect(gem_file_text.include?("okcomputer")).to eq true
      expect(gem_file_text.include?("simpacker")).to eq true
      expect(gem_file_text.include?("rubocop")).to eq true
      expect(gem_file_text.include?("erb_lint")).to eq true
      expect(gem_file_text.include?("rspec-rails")).to eq true

      # checked application.rb
      application_file_text = File.read(file_path.call('config/application.rb'))
      expect(application_file_text.include?("config.time_zone = 'Tokyo'")).to eq true
      expect(application_file_text.include?("config.settings = config_for(:settings)")).to eq true
      expect(application_file_text.include?("config.generators do |g|")).to eq true
    end
  end
end
