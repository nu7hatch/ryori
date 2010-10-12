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
end
