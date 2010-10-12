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
    
    # Add content at the end of given file. If file doesn't exist then it will be
    # automaticaly created. 
    # 
    #   append("orange.txt", "- Hi! I'm an apple...")              # => 0
    #   append("orange.txt", "- Hey apple! hey apple! hey apple!") # => 0
    #   append("orange.txt", "- Whaaaat?!!!")                      # => 0
    #   append("orange.txt", "- ...kkknife...")                    # => 0
    #
    #   $ cat orange.txt
    #   - Hi! I'm an apple...
    #   - Hey apple! hey apple! hey apple!
    #   - Whaaaat?!!!
    #   - ...kkknife...
    def append(fname, content=nil, options={})
      if File.exists?(afname = absolutize(fname))
        File.open(afname, "a") { |f| f.write("\n#{content}") }
        return 0
      else
        mkfile(fname, content, options)
      end
    end
    alias :append_to_file :append
    alias :append_content :append
    
    # Add content at the begining of given file. If file doesn't exist then it will
    # be automaticaly created. 
    #
    #   prepend("counting.txt", "...3") # => 0
    #   prepend("counting.txt", "..2")  # => 0
    #   prepend("counting.txt", ".1")   # => 0
    #   prepend("counting.txt", "0")    # => 0
    #
    #   $ cat counting.txt
    #   0
    #   .1
    #   ..2
    #   ...3
    def prepend(fname, content=nil, options={})
      if File.exists?(afname = absolutize(fname))
        orig = File.open(afname, "r").read
        File.open(afname, "w") { |f| f.write("#{content}\n#{orig}") }
        return 0
      else
        mkfile(fname, content, options)
      end
    end
    alias :prepend_to_file :prepend
    alias :prepend_content :prepend
    
    # Insert content to specified place in file. If given file doesn't exist
    # then nothin will be injected. 
    #
    #   mkfile("sparta.txt", "This\nSPARTA!")              # => 0
    #   inject("sparta.txt", "is", :after => /^this/i)     # => 0
    #   inject("sparta.txt", "foo", :before => /^foobar/i) # => 1
    #
    #   $ cat sparta.txt
    #   This
    #   is
    #   SPARTA!
    def inject(fname, content=nil, options={})
      if File.exists?(afname = absolutize(fname))
        before, after = options.delete(:before), options.delete(:after)
        orig = File.open(afname, "r").read
        res = orig.split(/$/)
        res.each_with_index do |line, id|
          res[id] = [content, line].join("\n") if before && !after && line =~ before 
          res[id] = [line, content].join("\n") if after && !before && line =~ after
        end
        res = res.join
        File.open(afname, "w") { |f| f.write(res) }
        return orig != res ? 0 : 1
      else
        return 1
      end
    end
    alias :insert :inject
    alias :inject_to_file :inject
    alias :insert_to_file :inject
    alias :inject_content :inject
    alias :insert_content :inject
    
    # Returns absolute path to given file. 
    #
    #   gen = Ryori::Generator.new("/home/nu7hatch/foo")
    #   gen.absolutize("bar/bla") # => "/home/nu7hatch/foo/bar/bla"
    def absolutize(fname)
      File.join(root, fname)
    end
  end # Generator
end # Ryori
