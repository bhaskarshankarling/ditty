# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start

ENV['DATABASE_URL'] ||= 'sqlite::memory:'

require 'ditty'
require 'ditty/db'
require 'rspec'
require 'rack/test'
require 'factory_bot'
require 'database_cleaner'
require 'timecop'

if ENV['DATABASE_URL'] == 'sqlite::memory:'
  folder = File.expand_path(File.dirname(__FILE__) + '/../migrate')
  Sequel.extension :migration
  Sequel::Migrator.apply(DB, folder)

  # Seed the DB
  require 'ditty/seed'
end

Ditty.component :app
RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include FactoryBot::Syntax::Methods

  config.alias_example_to :fit, focus: true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    FactoryBot.find_definitions
    Timecop.freeze
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
