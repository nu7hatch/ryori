$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'stringio'
require 'ostruct'
require 'rspec'
require 'mocha'

require 'ryori'

module Helpers
  # Capture and silence output streams (stdout, stderr), and return it values.
  #
  #   capture { puts "This is sparta!" }
  #   last_stdout # => "This is sparta!"
  #   last_stderr # => ""   
  def capture
    @last_stdout = StringIO.new
    @last_stderr = StringIO.new
    begin
      $stdout = @last_stdout
      $stderr = @last_stderr
      yield
    ensure
      $stdout = STDERR
      $stderr = STDOUT
    end
    [@last_stdout.string, @last_stderr.string]
  end
  
  # Replace standard input with faked one StringIO. 
  def fake_stdin(text)
    begin
      $stdin = StringIO.new
      $stdin.puts(text)
      $stdin.rewind
      yield
    ensure
      $stdin = STDIN
    end
  end 

  # Returns last string written to captured output stream.
  def last_stdout
    @last_stdout.string if @last_stdout
  end
  
  # Returns last string written to captured error stream.
  def last_stderr
    @last_stdout.string if @last_stdout
  end

  # Executes code within given temp directory context. 
  def within_tmp(&block) 
    FileUtils.mkdir(dirname = File.join(File.dirname(__FILE__), 'tmp'))
    yield(File.expand_path(dirname))
  ensure
    FileUtils.rm_rf(dirname)
  end
  
  # Returns mock generator. 
  def mock_gen(opts={})
    Ryori::Generator.new(File.dirname(__FILE__)+"/tmp", opts)
  end
end

RSpec.configure do |config| 
  config.mock_with :mocha
  config.include Helpers
end

