module Ryori

  # Ryori Generator can help you with creating, copying and manipulating files, 
  # creating directories, and compile templates. In brief, it can help you 
  # eg. with creating structure of your projects or preparing recipes.
  #  
  # ==== Examples
  #
  #    gen = RawGenerator.new("/tmp/project")
  #    gen.touch("foo/bar")
  #    gen.mkfile("foo/spam.sh", "#!/bin/sh\nwhoami", :mode => 0755)
  #    gen.mkdir("foo/tmp")
  #    gen.mkdir("foo/log")
  #    gen.append("foo/log/bla.log", "first line")
  #    gen.append("foo/log/bla.log", "third line")
  #    gen.inject("foo/log/bla.log", "second line", :before => /^third line/)
  #    ...
  class Generator
    include Helpers
  
    # Project root directory.
    attr_reader :root
    # RawGenerator global settings. 
    attr_reader :options
  
    def initialize(root, options={})
      @root    = root
      @options = options
    end
  
    # Creates an empty file in project root directory.
    #
    #   touch("foo.txt")                   # => 0
    #   touch("foo/bar.sh", :mode => 0755) # => 0
    def touch(fname, options={})
      (result = raw_touch(fname, options)) == 0 ?
        log("touched", fname, :green, true) :
        log("can't touch", fname, :red, true)
      return result
    end
    
    # Creates file with given content.
    #
    #   mkfile("foo.txt", "This is foo.txt file")                             # => 0
    #   mkfile("foo/bar.sh", "#!/bin/sh\n\necho Hello world!", :mode => 0755) # => 0
    #   mkfile("foo/bar.sh", "Foo")                                           # => 1
    #   mkfile("foo/bar.sh", "Foo!", :force => true)                          # => 0
    def mkfile(fname, content="", options={})
      case result = raw_mkfile(fname, content, options)
        when 0 then log("created", fname, :green, true)
        when 2 then log("identical", fname, :blue, true)
      else
        log("exist", fname, :yellow, true) unless yes_to_all?
        resolve_conflict(fname) do
          (result = raw_mkfile(fname, content, options.merge(:force => true))) == 0 ?
            log("overwritten", fname, :blue, true) :
            log("can't overwrite", fname, :red, true)
          return result
        end 
      end
      return result
    end
    
    # Recursively creates directory in project root.
    #
    #   mkdir("foo")                        # => 0
    #   mkdir("foo/bar")                    # => 0
    #   mkdir("foo/bar")                    # => 1
    #   mkdir("private/one", :mode => 0600) # => 0
    def mkdir(dirname, options={})
      (result = raw_mkdir(dirname, options)) == 0 ?
        log("created", dirname, :green, true) :
        log("exist", dirname, :blue, true)
      return result
    end
    
    # Generates file from given ERB template. 
    #
    #   compile("./templates/foo.sh.tt", "foo.sh")                 # => 0
    #   compile("./templates/foo.sh.tt", "foo.sh", :force => true) # => 0
    def compile(src, dest, options={})
      mkfile(dest, ERB.new(File.open(src).read).result(binding), options)
    end
    
    # Copy files to given destination.
    #
    #   cp("./files/foo.jpg", "images/foo.jpg")                 # => 0
    #   cp("./files/foo.jpg", "images/foo.jpg", :force => true) # => 0 
    def cp(src, dest, options={})
      case result = raw_cp(src, dest, options)
        when 0 then log("copied", dest, :green, true)
        when 2 then log("identical", dest, :blue, true)
      else
        log("exist", dest, :yellow, true) unless yes_to_all?
        resolve_conflict(dest) do
          (result = raw_cp(src, dest, options.merge(:force => true))) == 0 ?
            log("overwritten", dest, :blue, true) :
            log("can't overwrite", dest, :red, true)
          return result
        end
      end
      return result
    end
  
    # Add content at the end of given file. If file doesn't exist then it will be
    # automaticaly created. 
    # 
    #   append("orange.txt", "- Hi! I'm an apple...")              # => -1
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
      case result = raw_append(fname, content, options)
        when 0  then log("updated", fname, :green, true)
        when -1 then log("created", fname, :green, true)
      else
        log("can't update", fname, :red, true)
      end
      return result
    end
    
    # Add content at the begining of given file. If file doesn't exist then it will
    # be automaticaly created. 
    #
    #   prepend("counting.txt", "...3") # => -1
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
      case result = raw_prepend(fname, content, options)
        when 0  then log("updated", fname, :green, true)
        when -1 then log("created", fname, :green, true)
      else
        log("can't update", fname, :red, true)
      end
      return result
    end
    
    # Insert content to specified place in file. If given file doesn't exist
    # then nothing will be injected. 
    #
    #   mkfile("sparta.txt", "This\nSPARTA!")              # => 0
    #   inject("sparta.txt", "is", :after => /^this/i)     # => 0
    #   inject("sparta.txt", "foo", :before => /^foobar/i) # => 1
    #
    #   $ cat sparta.txt
    #   This
    #   is
    #   SPARTA!
    def inject(fname, content, options={})
      (result = raw_inject(fname, content, options)) == 0 ?
        log("updated", fname, :green, true) :
        log("can't update", fname, :yellow, true)
      return result
    end

    # It displays help message for conflicting files. 
    def help
      say! "y - yes, overwrite it"
      say! "n - no, don't overwrite it"
      say! "a - overwrite this and all others"
      say! "q - abort and quit"
      say! "h - show this help message"
    end

    # Displays prompt when specified file already exists. 
    def conflict_prompt(fname)
      unless yes_to_all?
        say("The #{absolute_path(fname)} exists, overwrite it? (enter \"h\" for help) [Ynaqh]: ", :yellow)
        $stdin.gets.to_s.chomp.downcase
      end
    end
    
    # It helps resolve conflict when specified file already exists.
    def resolve_conflict(fname, &block)
      decision = conflict_prompt(fname)
      decision = "y" if yes_to_all!(decision == "a") || decision == ""
      case decision
        when "y" then return yield
        when "n" then return 1
        when "h" then help
        when "q" then exit(0)
      end
      return resolve_conflict(fname, &block)
    end
      
    # Returns absolute path to given file. 
    #
    #   gen = Ryori::RawGenerator.new("/home/nu7hatch/foo")
    #   gen.absolute_path("bar/bla") # => "/home/nu7hatch/foo/bar/bla"
    def absolute_path(fname)
      File.expand_path(File.join(root, fname))
    end
    
    # This backlog can be used eg. for test purpose. It keeps all operations
    # made in current instance of generator. The log format looks like this: 
    #
    #   [
    #     [:created, "/home/foo/bar.rb"],
    #     [:created, "/home/foo/bar/spam.rb"],
    #     [:identical, "/home/foo/bar/eggs.rb"],
    #     [:exist, "/home/foo/bar/bla.rb"],
    #     [:override, "/home/foo/bar/bla.rb"]
    #   ]
    def backlog
      @backlog ||= []
    end
    
    # Store given operation on file in log and say about it on stdout. 
    def log(operation, name, color=nil, bold=false)
      say!(c(a(operation.to_s, 20), color, bold) + " " + name)
      backlog << [operation.to_s.gsub(/\W/, "_").to_sym, absolute_path(name)]
      nil
    end
    
    # If condition is <tt>true</tt> then all operations will be forced. 
    def yes_to_all!(condition)
      @yes_to_all ||= !!condition
    end
    
    # All operations will be forced when it's <tt>true</tt>.
    def yes_to_all?
      !!@yes_to_all
    end
    
    def raw_touch(fname, options={})
      raw_mkdir(File.dirname(fname)) and FileUtils.touch(absolute_path(fname), options) and 0
    end
    
    def raw_mkfile(fname, content="", options={})
      raw_mkdir(File.dirname(fname)) and begin
        if File.exists?(aname = absolute_path(fname)) && !options.delete(:force)
          return File.open(aname).read == content ? 2 : 1
        else
          File.open(absolute_path(fname), "w+") {|f| f.write(content)} and \
          raw_touch(fname, options) and \
          return 0
        end
      end
    end
    
    def raw_mkdir(dirname, options={})
      File.exists?(dirname = absolute_path(dirname)) ? 1 : (FileUtils.mkdir_p(dirname) and 0)
    end
    
    def raw_compile(src, dest, options={})
      raw_mkfile(dest, ERB.new(File.open(src).read).result(binding), options)
    end

    def raw_cp(src, dest, options={})
      raw_mkdir(File.dirname(dest)) and begin
        if File.exists?(absolute_path(dest)) && !options.delete(:force)
          return File.open(src).read ==  File.open(absolute_path(dest)).read ? 2 : 1
        else
          FileUtils.cp(src, absolute_path(dest)).nil? and raw_touch(dest, options) and return 0
        end
      end
    end
    
    def raw_append(fname, content=nil, options={})
      if File.exists?(afname = absolute_path(fname))
        File.open(afname, "a") { |f| f.write("\n#{content}") }
        return 0
      else
        result = raw_mkfile(fname, content, options)
        result == 0 ? -1 : result
      end
    end
    
    def raw_prepend(fname, content=nil, options={})
      if File.exists?(afname = absolute_path(fname))
        orig = File.open(afname, "r").read
        File.open(afname, "w") { |f| f.write("#{content}\n#{orig}") }
        return 0
      else
        result = raw_mkfile(fname, content, options)
        result == 0 ? -1 : result
      end
    end
    
    def raw_inject(fname, content=nil, options={})
      if File.exists?(afname = absolute_path(fname))
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
  end # Generator
end # Ryori
