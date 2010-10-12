require "fileutils"
require "erb"

module Ryori
  class Generator
  
    # Project root directory.
    attr_reader :root
    
    # Generator global settings. 
    attr_reader :options
  
    # Examples:
    #
    #   gen = Ryori::Generator.new("/path/to/project/root")
    #   gen.mkfile(".foo/config", "# This is configuration file")
    #   gen.mkdir(".foo/database")
    #   ...
    def initialize(root, options={})
      @root    = root
      @options = options
    end
  
    # Creates an empty file in project root directory.
    #
    #   touch("foo.txt")                   # => 0
    #   touch("foo/bar.sh", :mode => 0755) # => 0
    def touch(fname, options={})
      mkdir(File.dirname(fname)) and FileUtils.touch(absolutize(fname), options) and 0
    end
    
    # Creates file with given content.
    #
    #   mkfile("foo.txt", "This is foo.txt file")                             # => 0
    #   mkfile("foo/bar.sh", "#!/bin/sh\n\necho Hello world!", :mode => 0755) # => 0
    #   mkfile("foo/bar.sh", "Foo")                                           # => 1
    #   mkfile("foo/bar.sh", "Foo!", :force => true)                          # => 0
    def mkfile(fname, content="", options={})
      mkdir(File.dirname(fname)) and begin
        if File.exists?(absolutize(fname)) && !options.delete(:force)
          return 1
        else
          File.open(absolutize(fname), "w+") {|f| f.write(content)} and \
          touch(fname, options) and \
          return 0
        end
      end
    end
    alias :makefile :mkfile
    alias :make_file :mkfile
    
    # Recursively creates directory in project root.
    #
    #   mkdir("foo")                        # => 0
    #   mkdir("foo/bar")                    # => 0
    #   mkdir("foo/bar")                    # => 1
    #   mkdir("private/one", :mode => 0600) # => 0
    def mkdir(dirname, options={})
      File.exists?(dirname = absolutize(dirname)) ? 1 : (FileUtils.mkdir_p(dirname) and 0)
    end
    alias :makedir :mkdir
    alias :make_dir :mkdir
    
    # Generates file from given ERB template. 
    #
    #   gen("foo.sh", "./templates/foo.sh.tt")                 # => 0
    #   gen("foo.sh", "./templates/foo.sh.tt", :force => true) # => 0
    def gen(dest, src, options={})
      mkfile(dest, ERB.new(File.open(src).read).result(binding), options)
    end
    alias :generate :gen
    alias :genfile :gen
    alias :gen_file :gen
    alias :generate_file :gen

    # Copy files to given destination.
    #
    #   cp("images/foo.jpg", "./files/foo.jpg")                 # => 0
    #   cp("images/foo.jpg", "./files/foo.jpg", :force => true) # => 0 
    def cp(dest, src, options={})
      mkdir(File.dirname(dest)) and begin
        if File.exists?(absolutize(dest)) && !options.delete(:force)
          return 1
        else
          FileUtils.cp(src, absolutize(dest)).nil? and touch(dest, options) and return 0
        end
      end
    end
    alias :copy :cp
    alias :cpfile :cp
    alias :copyfile :cp
    alias :copy_file :cp
    
    # Returns absolute path to given file. 
    #
    #   gen = Ryori::Generator.new("/home/nu7hatch/foo")
    #   gen.absolutize("bar/bla") # => "/home/nu7hatch/foo/bar/bla"
    def absolutize(fname)
      File.join(root, fname)
    end
  end # Generator
end # Ryori
