RACK_ENV = 'test' unless defined?(RACK_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
Dir[File.expand_path(File.dirname(__FILE__) + "/support/**/*.rb")].each(&method(:require))
Dir[File.expand_path(File.dirname(__FILE__) + "/../app/helpers/**/*.rb")].each(&method(:require))
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'shoulda/matchers'
require "rack_session_access/capybara"
require 'billy/capybara/rspec'
require 'fantaskspec'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods

  #
  # 2017-4-5 http://stackoverflow.com/questions/8178120/capybara-with-js-true-causes-test-to-fail
  #
  conf.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  conf.before(:each) do
    # set the default
    DatabaseCleaner.strategy = :transaction
  end

  conf.before(:each, type: :feature) do
    DatabaseCleaner.strategy = :truncation
  end

  conf.before(:each) do
    DatabaseCleaner.start
  end

  conf.append_after(:each) do
    DatabaseCleaner.clean
  end

  conf.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Factory Girl
  conf.include FactoryGirl::Syntax::Methods

  conf.before(:suite) do
    FactoryGirl.find_definitions
  end


##
##  conf.before(:suite) do
##    if conf.use_transactional_fixtures?
##      raise(<<-MSG)
##        Delete line `conf.use_transactional_fixtures = true` from rails_helper.rb
##        (or set it to false) to prevent uncommitted transactions being used in
##        JavaScript-dependent specs.
##
##        During testing, the app-under-test that the browser driver connects to
##        uses a different database connection to the database connection used by
##        the spec. The app's database connection would not be able to access
##        uncommitted transaction data setup over the spec's database connection.
##      MSG
##    end
##    DatabaseCleaner.clean_with(:truncation)
##  end
#
#  conf.before(:each) do
#    DatabaseCleaner.strategy = :transaction
#  end
#
#  conf.before(:each, type: :feature) do
#    # :rack_test driver's Rack app under test shares database connection
#    # with the specs, so continue to use transaction strategy for speed.
#    driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test
#
#    if !driver_shares_db_connection_with_specs
#      # Driver is probably for an external browser with an app
#      # under test that does *not* share a database connection with the
#      # specs, so use truncation strategy.
#      DatabaseCleaner.strategy = :truncation
#    end
#  end
#
#  conf.before(:each) do
#    DatabaseCleaner.start
#  end
#
#  conf.append_after(:each) do
#    DatabaseCleaner.clean
#  end

  # Capybara
  conf.include Capybara::DSL

  # Shoulda
  conf.include(Shoulda::Matchers::ActiveModel, type: :model)
  conf.include(Shoulda::Matchers::ActiveRecord, type: :model)
end


# You can use this method to custom specify a Rack app
# you want rack-test to invoke:
#
#   app YesOrNo::App
#   app YesOrNo::App.tap { |a| }
#   app(YesOrNo::App) do
#     set :foo, :bar
#   end
#
def app(app = nil, &blk)
  @app ||= block_given? ? app.instance_eval(&blk) : app
  @app ||= Padrino.application
end

##########
# 2017-4-13
# cf. with the test config in `app/app.rb`. It's a lot nicer to put it here,
# but then the admin application doesn't run for the tests. I don't know
# why this is
#
#app(YesOrNo::App) do
#  use RackSessionAccess::Middleware
#  set :protect_from_csrf, false
#  set :delivery_method, :test  
#end

# Capybara
#Capybara.javascript_driver = :poltergeist
Capybara.javascript_driver = :poltergeist_billy
#Capybara.ignore_hidden_elements = true
#Capybara.default_max_wait_time = 1000
#Capybara.javascript_driver = :webkit
Capybara.app = app

#
# Conveniently get the session hash
#
#def session
#  last_request.env['rack.session']
#end
