require File.expand_path("../../spec_helper", __FILE__)

describe Wizard::Spells::MakeDir do
  subject do
    Wizard::Spells::MakeDir
  end
  
  describe "#initialize" do
    it "should set given dirname" do
      subject.new("/path/to/dir").dirname.should == "/path/to/dir"
    end
    
    it "should have empty chmod by default" do
      subject.new("/path/to/dir").chmod.should == nil
    end
    
    context "given :mode" do
      it "should set it" do
        subject.new("/path/to/dir", :mode => 755).chmod.should == 755
      end
    end
  end
  
  describe "#perform" do
    subject do
      Wizard::Spells::MakeDir.new("/path/to/dir")
    end
    
    context "when specified directory exists" do
      it "should set :exist status" do
        File.expects(:exist?).returns(true)
        spell = subject
        spell.perform.should == :exist
        spell.should be_exist
      end
    end
    
    context "when specified directory doesn't exist" do
      context "and user have access to create it" do
        it "should set :created status" do
          FileUtils.expects(:mkdir_p).with("/path/to/dir", :mode => 644).returns("/path/to/dir")
          spell = subject
          spell.perform.should == :created
          spell.should be_created
        end
      end
      
      context "and user don't have access to create it" do
        it "should set :noaccess status" do
          FileUtils.expects(:mkdir_p).with("/path/to/dir", :mode => 644).raises(Errno::EACCES)
          spell = subject
          spell.perform.should == :noaccess
          spell.should be_noaccess
        end
      end
    end
    
    context "when unknown error raised while creating directory" do
      it "shouldn't create it and set :noaccess status" do
        FileUtils.expects(:mkdir_p).with("/path/to/dir", :mode => 644).raises(Exception)
        spell = subject
        spell.perform.should == :error
        spell.should be_error
      end
    end
    
    context "when directory can't been created" do
      it "shouldn't create it and set :error status" do
        FileUtils.expects(:mkdir_p).with("/path/to/dir", :mode => 644).returns(false)
        spell = subject
        spell.perform.should == :error
        spell.should be_error
      end
    end
  end
end

