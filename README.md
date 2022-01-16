# My Rails Template

My application template for Ruby on Rails.

# Usage

## Genarate Application by Temaplate and railsrc

```sh
$ clone git@github.com:Madogiwa0124/my_rails_template.git
$ cd my_rails_template
$ bundle install
$ XDG_CONFIG_HOME=./ bundle exec rails new sample_app -m ./rails/template.rb

Using --skip-bundle --skip-action-mailbox --skip-action-text --skip-active-storage --skip-action-cable --skip-test --skip-test-unit --skip-jbuilder --skip-spring --skip-turbolinks --skip-sprockets --skip-javascript --database=postgresql --force from my_rails_template/rails/railsrc
    executed by using template and railsrc.
```

## After genarate

```
$ docker-compose up -d
$ cd sample_app
$ bundle install
$ bundle exec rubocop -A
$ bundle exec rails g rspec:install
```

- Fix `application.rb` and enviroments files.
- Fix `spec/spec_helper` and `spec/rails_helper`.
  - Configured `capybara`, `simplecov`

## Check

```sh
$ cd sample_app
$ env DATABASE_URL=postgres://postgres:password@localhost:5432 REDIS_URL=redis://localhost:6379/0 bin/rails db:prepare
$ bundle exec rubocop
$ bundle exec erblint
$ bundle exec rspec
$ env DATABASE_URL=postgres://postgres:password@localhost:5432 REDIS_URL=redis://localhost:6379/0 bin/rails s
$ env DATABASE_URL=postgres://postgres:password@localhost:5432 REDIS_URL=redis://localhost:6379/0 bundle exec sidekiq
```
