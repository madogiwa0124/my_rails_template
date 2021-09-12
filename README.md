# My Rails Template

My application template for Ruby on Rails.

# Usage

## Genarate Application by Temaplate and railsrc

``` sh
$ clone git@github.com:Madogiwa0124/my_rails_template.git
$ cd my_rails_template
$ bundle install
$ XDG_CONFIG_HOME=./ bundle exec rails new sample_app -m ./rails/template.rb

Using --skip-bundle --skip-action-mailbox --skip-action-text --skip-active-storage --skip-action-cable --skip-test --skip-test-unit --skip-jbuilder --skip-spring --skip-turbolinks --skip-sprockets --skip-javascript --database=postgresql --force from my_rails_template/rails/railsrc
      create  
      create  README.md
      create  Rakefile
      create  .ruby-version
      create  config.ru
      create  .gitignore
      create  .gitattributes
      create  Gemfile
         run  git init from "."
Initialized empty Git repository in my_rails_template/sample_app/.git/
      create  app
      create  app/assets/config/manifest.js
      create  app/assets/stylesheets/application.css
      create  app/channels/application_cable/channel.rb
      create  app/channels/application_cable/connection.rb
      create  app/controllers/application_controller.rb
      create  app/helpers/application_helper.rb
      create  app/javascript/channels/consumer.js
      create  app/javascript/channels/index.js
      create  app/javascript/packs/application.js
      create  app/jobs/application_job.rb
      create  app/mailers/application_mailer.rb
      create  app/models/application_record.rb
      create  app/views/layouts/application.html.erb
      create  app/views/layouts/mailer.html.erb
      create  app/views/layouts/mailer.text.erb
      create  app/assets/images
      create  app/assets/images/.keep
      create  app/controllers/concerns/.keep
      create  app/models/concerns/.keep
      create  bin
      create  bin/rails
      create  bin/rake
      create  bin/setup
      create  bin/spring
      create  bin/yarn
      remove  bin/spring
      remove  bin/yarn
      create  config
      create  config/routes.rb
      create  config/application.rb
      create  config/environment.rb
      create  config/puma.rb
      create  config/environments
      create  config/environments/development.rb
      create  config/environments/production.rb
      create  config/environments/test.rb
      create  config/initializers
      create  config/initializers/application_controller_renderer.rb
      create  config/initializers/assets.rb
      create  config/initializers/backtrace_silencers.rb
      create  config/initializers/content_security_policy.rb
      create  config/initializers/cookies_serializer.rb
      create  config/initializers/cors.rb
      create  config/initializers/filter_parameter_logging.rb
      create  config/initializers/inflections.rb
      create  config/initializers/mime_types.rb
      create  config/initializers/new_framework_defaults_6_1.rb
      create  config/initializers/permissions_policy.rb
      create  config/initializers/wrap_parameters.rb
      create  config/locales
      create  config/locales/en.yml
      create  config/master.key
      append  .gitignore
      create  config/boot.rb
      create  config/database.yml
      create  db
      create  db/seeds.rb
      create  lib
      create  lib/tasks
      create  lib/tasks/.keep
      create  lib/assets
      create  lib/assets/.keep
      create  log
      create  log/.keep
      create  public
      create  public/404.html
      create  public/422.html
      create  public/500.html
      create  public/apple-touch-icon-precomposed.png
      create  public/apple-touch-icon.png
      create  public/favicon.ico
      create  public/robots.txt
      create  tmp
      create  tmp/.keep
      create  tmp/pids
      create  tmp/pids/.keep
      create  tmp/cache
      create  tmp/cache/assets
      create  vendor
      create  vendor/.keep
      remove  app/javascript
      remove  config/initializers/assets.rb
      remove  app/javascript/channels
      remove  app/channels
      remove  test/channels
      remove  config/initializers/cors.rb
      remove  config/initializers/new_framework_defaults_6_1.rb
       apply  my_rails_template/rails/template.rb
     gemfile    okcomputer
     gemfile    lograge
     gemfile    redis
     gemfile    sidekiq
     gemfile    simpacker
     gemfile    rails-i18n (~> 6.0.0)
     gemfile    group :development, :test
        gsub    Gemfile
     gemfile    bullet
     gemfile    brakeman
     gemfile    erb_lint
     gemfile    rspec-rails
     gemfile    factory_bot_rails
     gemfile    rubocop
     gemfile    rubocop-performance
     gemfile    rubocop-rails
     gemfile    rubocop-rspec
        gsub    Gemfile
     gemfile    group :development
        gsub    Gemfile
     gemfile    letter_opener_web (~> 1.0)
        gsub    Gemfile
     gemfile    group :test
        gsub    Gemfile
     gemfile    capybara
     gemfile    simplecov
        gsub    Gemfile
 initializer    okcomputer.rb
 initializer    lograge.rb
 initializer    sidekiq.rb
       route    For LetterOpenerWeb
mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

# For Sidekiq Web UI
require 'sidekiq/web'
mount Sidekiq::Web, at: '/sidekiq'
      create    .rubocop.yml
      create    .erb-lint.yml
      create    .editorconfig
      create    config/sidekiq.yml
      create    config/simpacker.yml
      create    config/settings.yml
       force    config/database.yml
       force    app/models/application_record.rb
         run    cp .gitignore .dockerignore from "."
    executed by using template and railsrc.
```

## After genarate

```
$ docker-compose up -d
$ cd sampla_app
$ bundle install
$ bundle exec rubocop -A
$ bundle exec rails g rspec:install
$ env DATABASE_URL=postgres://postgres:password@localhost:5432 REDIS_URL=redis://localhost:6379/0 bin/rails db:prepare
```

* Fix `application.rb` and enviroments files.
* Fix `spec/spec_helper` and `spec/rails_helper`.
  - Configured `capybara`, `simplecov`


## Check

``` sh
$ bundle exec rubocop
$ bundle exec erblint
$ bundle exec rspec
$ env DATABASE_URL=postgres://postgres:password@localhost:5432 REDIS_URL=redis://localhost:6379/0 bin/rails s
$ env DATABASE_URL=postgres://postgres:password@localhost:5432 REDIS_URL=redis://localhost:6379/0 bundle exec sidekiq
```
