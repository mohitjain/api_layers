$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'api_layers'

require 'active_mocker/mock'
require 'test_record'

Dir[File.join(Dir.pwd, "spec/support/**/*.rb")].each { |file| require file }

ENV["RAILS_ENV"] ||= 'test'
