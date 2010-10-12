require "spec_helper"

describe "Ryori generator" do 
  def mock_gen
    Ryori::Generator.new(File.dirname(__FILE__)+"/tmp")
  end
  
  it "should properly set root dir on initialize" do 
    gen = Ryori::Generator.new(Dir.pwd)
    gen.root.should == Dir.pwd
  end
  
  it "should properly set args on initialize" do 
    gen = Ryori::Generator.new(Dir.pwd, :foo => :bar)
    gen.options.should == {:foo => :bar}
  end
  
  it "#absolutize should return an absolute path from given one" do 
    gen = mock_gen
    gen.absolutize("foo/bar/bla").should == File.dirname(__FILE__)+"/tmp/foo/bar/bla"
  end
  
  it "should be able to touch empty file" do 
    within_tmp do |dir|
      gen = mock_gen
      gen.touch("foo.txt").should == 0
      gen.touch("foo/bar.txt").should == 0
      File.should be_exists(dir+"/foo.txt")
      File.should be_exists(dir+"/foo/bar.txt")
    end
  end
  
  it "should be able to recursive create directory" do 
    within_tmp do |dir|
      gen = mock_gen
      gen.mkdir("foo/bar/bla").should == 0
      gen.mkdir("foo/barra").should == 0
      gen.mkdir("foo/barra").should == 1
      File.should be_directory(dir+"/foo/bar/bla")
      File.should be_directory(dir+"/foo/barra")
    end
  end
  
  it "should be able to create file with given content" do 
    within_tmp do |dir|
      gen = mock_gen
      gen.mkfile("foo.txt", "Fooo!").should == 0
      gen.mkfile("foo/bar.sh", "foobar!").should == 0
      gen.mkfile("foo/bar.sh", "woop!").should == 1
      gen.mkfile("foo/bar.sh", "woop!", :force => true).should == 0
      File.should be_exists(dir+"/foo.txt")
      File.should be_exists(dir+"/foo/bar.sh")
    end
  end
  
  it "should be able to generate file from given template" do 
    within_tmp do |dir|
      gen = mock_gen
      foo_txt_tt = "This is <%= 'example' %> file..."
      gen.mkfile("foo.txt.tt", foo_txt_tt) 
      gen.gen("foo.txt", dir+"/foo.txt.tt").should == 0
      gen.gen("foo.txt", dir+"/foo.txt.tt").should == 1
      gen.gen("foo.txt", dir+"/foo.txt.tt", :force => true).should == 0
      File.should be_exists(dir+"/foo.txt")
      File.open(dir+"/foo.txt").read.should == "This is example file..."
    end
  end
  
  it "should be able to copy file to given destination" do 
    within_tmp do |dir|
      gen = mock_gen
      foo_txt = "This is example file..."
      gen.mkfile("files/foo.txt", foo_txt)
      gen.cp("foo.txt", dir+"/files/foo.txt").should == 0
      gen.cp("foo.txt", dir+"/files/foo.txt").should == 1
      gen.cp("foo.txt", dir+"/files/foo.txt", :force => true).should == 0
      File.should be_exists(dir+"/foo.txt")
      File.open(dir+"/foo.txt").read.should == "This is example file..."
    end
  end
  
  it "should be able to append content to file" do 
    within_tmp do |dir|
      gen = mock_gen
      gen.mkfile("foo.txt", "This").should == 0
      gen.append("foo.txt", "is").should == 0
      gen.append("foo.txt", "SPARTA!").should == 0
      gen.append("bar.txt", "Hello!").should == 0
      File.should be_exists(dir+"/foo.txt")
      File.should be_exists(dir+"/bar.txt")
      File.open(dir+"/foo.txt").read.should == "This\nis\nSPARTA!"
      File.open(dir+"/bar.txt").read.should == "Hello!"
    end
  end
  
  it "should be able to prepend content to file" do 
    within_tmp do |dir|
      gen = mock_gen
      gen.mkfile("foo.txt", "SPARTA!").should == 0
      gen.prepend("foo.txt", "is").should == 0
      gen.prepend("foo.txt", "This").should == 0
      gen.prepend("bar.txt", "Hello!").should == 0
      File.should be_exists(dir+"/foo.txt")
      File.should be_exists(dir+"/bar.txt")
      File.open(dir+"/foo.txt").read.should == "This\nis\nSPARTA!"
      File.open(dir+"/bar.txt").read.should == "Hello!"
    end
  end
  
  it "should be able to inject content to specified place in file" do 
    within_tmp do |dir|
      gen = mock_gen
      gen.mkfile("foo.txt", "This\nSPARTA!").should == 0
      gen.inject("foo.txt", "is", :after => /^This/m).should == 0
      gen.inject("foo.txt", "Foo...", :after => /^foooo/m).should == 1
      gen.inject("foo.txt", "Yeah!", :before => /^This/m).should == 0
      gen.inject("bar.txt", "Foo").should == 1
      File.should be_exists(dir+"/foo.txt")
      File.should_not be_exists(dir+"/bar.txt")
      File.open(dir+"/foo.txt").read.should == "Yeah!\nThis\nis\nSPARTA!"
    end
  end 
end
