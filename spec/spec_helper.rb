$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'spec'
require 'spec/autorun'
require 'ryori'
require 'stringio'

module Helpers
  def within_tmp(&block) 
    FileUtils.mkdir(fname = File.join(File.dirname(__FILE__), 'tmp'))
    yield(fname)
  ensure
    FileUtils.rm_rf(fname)
  end

  def capture(*streams)
    streams.map! { |stream| stream.to_s }
    begin
      result = StringIO.new
      streams.each { |stream| eval "$#{stream} = result" }
      yield
    ensure
      streams.each { |stream| eval("$#{stream} = #{stream.upcase}") }
    end
    result.string
  end
end

Spec::Runner.configure do |config|
  config.mock_with :mocha
  config.send :include, Helpers
end
