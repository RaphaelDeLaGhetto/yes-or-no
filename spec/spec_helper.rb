RACK_ENV = 'test' unless defined?(RACK_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
Dir[File.expand_path(File.dirname(__FILE__) + "/../app/helpers/**/*.rb")].each(&method(:require))
require 'shoulda/matchers'

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
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

