require "spec_helper"

describe "Ryori generator" do
  subject { Ryori::Generator }

  it "should properly set root dir on initialize" do 
    gen = subject.new(Dir.pwd)
    gen.root.should == Dir.pwd
  end
  
  it "should properly set args on initialize" do 
    gen = subject.new(Dir.pwd, :foo => :bar)
    gen.options.should == {:foo => :bar}
  end
  
  it "#absolutize should return an absolute path from given one" do 
    gen = mock_gen
    gen.absolutize("foo/bar/bla").should == File.dirname(__FILE__)+"/tmp/foo/bar/bla"
  end
  
  it "should be able to touch empty file" do 
    within_tmp do |dir|
      gen = mock_gen
      gen.raw_touch("foo.txt").should == 0
      gen.raw_touch("foo/bar.txt").should == 0
      File.should be_exists(dir+"/foo.txt")
      File.should be_exists(dir+"/foo/bar.txt")
    end
  end
  
  it "should be able to recursive create directory" do 
    within_tmp do |dir|
      gen = mock_gen
      gen.raw_mkdir("foo/bar/bla").should == 0
      gen.raw_mkdir("foo/barra").should == 0
      gen.raw_mkdir("foo/barra").should == 1
      File.should be_directory(dir+"/foo/bar/bla")
      File.should be_directory(dir+"/foo/barra")
    end
  end
  
  it "should be able to create file with given content" do 
    within_tmp do |dir|
      gen = mock_gen
      gen.raw_mkfile("foo.txt", "Fooo!").should == 0
      gen.raw_mkfile("foo/bar.sh", "foobar!").should == 0
      gen.raw_mkfile("foo/bar.sh", "woop!").should == 1
      gen.raw_mkfile("foo/bar.sh", "woop!", :force => true).should == 0
      gen.raw_mkfile("foo/bar.sh", "woop!").should == 2
      File.should be_exists(dir+"/foo.txt")
      File.should be_exists(dir+"/foo/bar.sh")
    end
  end
  
  it "should be able to generate file from given template" do 
    within_tmp do |dir|
      gen = mock_gen
      foo_txt_tt = "This is <%= 'example' %> file..."
      gen.raw_mkfile("foo.txt.tt", foo_txt_tt) 
      gen.raw_compile(dir+"/foo.txt.tt", "foo.txt").should == 0
      gen.raw_compile(dir+"/foo.txt.tt", "foo.txt").should == 2
      gen.raw_compile(dir+"/foo.txt.tt", "foo.txt", :force => true).should == 0
      File.should be_exists(dir+"/foo.txt")
      File.open(dir+"/foo.txt").read.should == "This is example file..."
    end
  end
  
  it "should be able to copy file to given destination" do 
    within_tmp do |dir|
      gen = mock_gen
      foo_txt = "This is example file..."
      gen.raw_mkfile("files/foo.txt", foo_txt)
      bar_txt = "This is another example file..."
      gen.raw_mkfile("files/bar.txt", bar_txt)
      gen.raw_cp(dir+"/files/foo.txt", "foo.txt").should == 0
      gen.raw_cp(dir+"/files/foo.txt", "foo.txt").should == 2
      gen.raw_cp(dir+"/files/bar.txt", "foo.txt").should == 1
      gen.raw_cp(dir+"/files/bar.txt", "foo.txt", :force => true).should == 0
      File.should be_exists(dir+"/foo.txt")
      File.open(dir+"/foo.txt").read.should == "This is another example file..."
    end
  end
  
  it "should be able to append content to file" do 
    within_tmp do |dir|
      gen = mock_gen
      gen.raw_mkfile("foo.txt", "This").should == 0
      gen.raw_append("foo.txt", "is").should == 0
      gen.raw_append("foo.txt", "SPARTA!").should == 0
      gen.raw_append("bar.txt", "Hello!").should == -1
      File.should be_exists(dir+"/foo.txt")
      File.should be_exists(dir+"/bar.txt")
      File.open(dir+"/foo.txt").read.should == "This\nis\nSPARTA!"
      File.open(dir+"/bar.txt").read.should == "Hello!"
    end
  end
  
  it "should be able to prepend content to file" do 
    within_tmp do |dir|
      gen = mock_gen
      gen.raw_mkfile("foo.txt", "SPARTA!").should == 0
      gen.raw_prepend("foo.txt", "is").should == 0
      gen.raw_prepend("foo.txt", "This").should == 0
      gen.raw_prepend("bar.txt", "Hello!").should == -1
      File.should be_exists(dir+"/foo.txt")
      File.should be_exists(dir+"/bar.txt")
      File.open(dir+"/foo.txt").read.should == "This\nis\nSPARTA!"
      File.open(dir+"/bar.txt").read.should == "Hello!"
    end
  end
  
  it "should be able to inject content to specified place in file" do 
    within_tmp do |dir|
      gen = mock_gen
      gen.raw_mkfile("foo.txt", "This\nSPARTA!").should == 0
      gen.raw_inject("foo.txt", "is", :after => /^This/m).should == 0
      gen.raw_inject("foo.txt", "Foo...", :after => /^foooo/m).should == 1
      gen.raw_inject("foo.txt", "Yeah!", :before => /^This/m).should == 0
      gen.raw_inject("bar.txt", "Foo").should == 1
      File.should be_exists(dir+"/foo.txt")
      File.should_not be_exists(dir+"/bar.txt")
      File.open(dir+"/foo.txt").read.should == "Yeah!\nThis\nis\nSPARTA!"
    end
  end 

  it "should properly store all operations in backlog" do 
    gen = mock_gen
    gen.expects(:say!).once
    gen.log(:create, "foo/bar.rb")
    gen.backlog.should == [[:create, File.join(File.dirname(__FILE__), "tmp/foo/bar.rb")]] 
  end
  
  it "should properly display help for conflicting files" do 
    capture { mock_gen.help }
    last_stdout.should == "y - yes, overwrite it\nn - no, don't overwrite it\na - " +
      "overwrite this and all others\nq - abort and quit\nh - show this help message\n"
  end
  
  it "should properly display conflict prompt" do 
    within_tmp do |dir|
      fake_stdin("n") do
        capture do
          decision = mock_gen.conflict_prompt("foo.rb")
          decision.should == "n"
        end
        last_stdout.should == "\e[0;33mThe ./spec/tmp/foo.rb exists, overwrite it? (enter "+
          "\"h\" for help) [Ynaqh]: \e[0m"
      end
    end
  end
  
  it "should properly resolve files conflicts" do 
    within_tmp do |dir|
      fake_stdin("n") do 
        capture { mock_gen.resolve_conflict("foo.rb") {}.should == 1 }
      end
      fake_stdin("a") do 
        gen = mock_gen
        capture { gen.resolve_conflict("foo.rb") { 0 }.should == 0 }
        gen.should be_yes_to_all
      end
      fake_stdin("h\nn") do 
        gen = mock_gen
        gen.expects(:help).once
        capture { gen.resolve_conflict("foo.rb") {}.should == 1 }
      end
      fake_stdin("y") do 
        capture { mock_gen.resolve_conflict("foo.rb") { 0 }.should == 0 }
      end
      fake_stdin("") do 
        capture { mock_gen.resolve_conflict("foo.rb") { 0 }.should == 0 }
      end
      fake_stdin("q") do 
        capture do
          lambda { mock_gen.resolve_conflict("foo.rb") {} }.should raise_error(SystemExit)
        end
      end
    end
  end
  
  it "should write proper output after execute #touch" do 
    within_tmp do |dir|
      capture { mock_gen.touch("foo/bar.rb") }
      last_stdout.should == "\e[1;32mtouched \e[0;30m............\e[0m\e[0m foo/bar.rb\n"
    end
  end
  
  it "should write proper output after execute #mkdir" do 
    within_tmp do |dir|
      capture { mock_gen.mkdir("foobar") }
      last_stdout.should == "\e[1;32mcreated \e[0;30m............\e[0m\e[0m foobar\n"
      capture { mock_gen.mkdir("foobar") }
      last_stdout.should == "\e[1;34mexist \e[0;30m..............\e[0m\e[0m foobar\n"
    end
  end
  
  it "should write proper output after execute #mkfile" do 
    within_tmp do |dir|
      capture { mock_gen.mkfile("foo.txt", "Hello world") }
      last_stdout.should == "\e[1;32mcreated \e[0;30m............\e[0m\e[0m foo.txt\n"
      capture { mock_gen.mkfile("foo.txt", "Hello world") }
      last_stdout.should == "\e[1;34midentical \e[0;30m..........\e[0m\e[0m foo.txt\n"
      fake_stdin("y") do
        capture { mock_gen.mkfile("foo.txt", "Yada yada yada!") }
        last_stdout.should == "\e[1;33mexist \e[0;30m..............\e[0m\e[0m foo.txt"+
          "\n\e[0;33mThe ./spec/tmp/foo.txt exists, overwrite it? (enter \"h\" for help) [Ynaqh]: "+
          "\e[0m\e[1;34moverwritten \e[0;30m........\e[0m\e[0m foo.txt\n"
      end
    end
  end
  
  it "should write proper output after execute #cp" do 
    within_tmp do |dir|
      foo_txt = "This is example file..."
      mock_gen.raw_mkfile("files/foo.txt", foo_txt)
      bar_txt = "This is another example file..."
      mock_gen.raw_mkfile("files/bar.txt", bar_txt)
      capture { mock_gen.cp(dir+"/files/foo.txt", "foo.txt") }
      last_stdout.should == "\e[1;32mcopied \e[0;30m.............\e[0m\e[0m foo.txt\n"
      capture { mock_gen.cp(dir+"/files/foo.txt", "foo.txt") }
      last_stdout.should == "\e[1;34midentical \e[0;30m..........\e[0m\e[0m foo.txt\n"
      fake_stdin("y") do
        capture { mock_gen.cp(dir+"/files/bar.txt", "foo.txt") }
        last_stdout.should == "\e[1;33mexist \e[0;30m..............\e[0m\e[0m foo.txt"+
          "\n\e[0;33mThe ./spec/tmp/foo.txt exists, overwrite it? (enter \"h\" for help) [Ynaqh]: "+
          "\e[0m\e[1;34moverwritten \e[0;30m........\e[0m\e[0m foo.txt\n"
      end
    end
  end
  
  it "should write proper output after execute #append" do 
    within_tmp do |dir|
      capture { mock_gen.append("foo.txt", "Hello") }
      last_stdout.should == "\e[1;32mcreated \e[0;30m............\e[0m\e[0m foo.txt\n"
      capture { mock_gen.append("foo.txt", "World!") }
      last_stdout.should == "\e[1;32mupdated \e[0;30m............\e[0m\e[0m foo.txt\n"
    end
  end
  
  it "should write proper output after execute #prepend" do 
    within_tmp do |dir|
      capture { mock_gen.prepend("foo.txt", "Hello") }
      last_stdout.should == "\e[1;32mcreated \e[0;30m............\e[0m\e[0m foo.txt\n"
      capture { mock_gen.prepend("foo.txt", "World!") }
      last_stdout.should == "\e[1;32mupdated \e[0;30m............\e[0m\e[0m foo.txt\n"
    end
  end
  
  it "should write proper output after execute #inject" do 
    within_tmp do |dir|
      mock_gen.raw_mkfile("foo.txt", "Hello\n")
      capture { mock_gen.inject("foo.txt", "World!", :after => /Hello/) }
      last_stdout.should == "\e[1;32mupdated \e[0;30m............\e[0m\e[0m foo.txt\n"
      capture { mock_gen.inject("foo.txt", "Nothing", :before => /Hurra!/) }
      last_stdout.should == "\e[1;33mcan't update \e[0;30m.......\e[0m\e[0m foo.txt\n"
      capture { mock_gen.inject("bar.txt", "Nothing", :before => /Hurra!/) }
      last_stdout.should == "\e[1;33mcan't update \e[0;30m.......\e[0m\e[0m bar.txt\n"
    end
  end
  
  it "should write proper output after execute #compile" do 
    within_tmp do |dir|
      foo_txt_tt = "This is <%= 'example' %> file..."
      mock_gen.raw_mkfile("foo.txt.tt", foo_txt_tt) 
      bar_txt_tt = "This is another <%= 'example' %> file..."
      mock_gen.raw_mkfile("bar.txt.tt", bar_txt_tt) 
      capture { mock_gen.compile(dir+"/foo.txt.tt", "foo.txt") }
      last_stdout.should == "\e[1;32mcreated \e[0;30m............\e[0m\e[0m foo.txt\n"
      capture { mock_gen.compile(dir+"/foo.txt.tt", "foo.txt") }
      last_stdout.should == "\e[1;34midentical \e[0;30m..........\e[0m\e[0m foo.txt\n"
      fake_stdin("y") do
        capture { mock_gen.compile(dir+"/bar.txt.tt", "foo.txt") }
        last_stdout.should == "\e[1;33mexist \e[0;30m..............\e[0m\e[0m foo.txt"+
          "\n\e[0;33mThe ./spec/tmp/foo.txt exists, overwrite it? (enter \"h\" for help) [Ynaqh]: "+
          "\e[0m\e[1;34moverwritten \e[0;30m........\e[0m\e[0m foo.txt\n"
      end
    end
  end
end
