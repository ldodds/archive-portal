ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'
  
Bundler.require :default, ENV['RACK_ENV'].to_sym
  
require_relative File.join('..', 'lib/archive-portal.rb')

VCR.configure do |c|
  c.cassette_library_dir = File.expand_path(File.dirname(__FILE__) + '/fixtures/vcr_cassettes')
  c.hook_into :webmock
end

RSpec.configure do |config|
  include Rack::Test::Methods

  config.color = true
  config.order = 'random'
    
end