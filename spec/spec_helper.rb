$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

ENV["APP_ENV"] = "test"

require 'rubygems'
require 'spec'
require 'spec/autorun'
require 'ryori'

module Helpers
  def within_tmp(&block) 
    FileUtils.mkdir(fname = File.join(File.dirname(__FILE__), 'tmp'))
    yield(fname)
  ensure
    FileUtils.rm_rf(fname)
  end
end

Spec::Runner.configure do |config|
  config.mock_with :mocha
  config.send :include, Helpers
end
