require File.expand_path("../../spec_helper", __FILE__)

describe Ryori::Makers::DirMaker do
  subject do
    Ryori::Makers::DirMaker
  end
  
  describe "#initialize" do
    it "should set given dirname" do
      subject.new("/path/to/dir").dirname.should == "/path/to/dir"
    end
    
    it "should set default chmod" do
      subject.new("/path/to/dir").chmod.should == 644
    end
    
    context "given :mode" do
      it "should set it" do
        subject.new("/path/to/dir", :mode => 755).chmod.should == 755
      end
    end
  end
  
  describe "#perform!" do
    subject do
      Ryori::Makers::DirMaker.new("/path/to/dir")
    end
    
    context "when given directory exists" do
      it "should set :exist status" do
        File.expects(:exist?).returns(true)
        subject.perform!.should == :exist
        subject.should be_exist
      end
    end
    
    context "when given directory doesn't exist" do
      context "and user have access to create it" do
        it "should set :created status" do
          FileUtils.expects(:mkdir_p).with("/path/to/dir", :mode => 644).returns("/path/to/dir")
          subject.perform!.should == :created
          subject.should be_created
        end
      end
      
      context "and user don't have access to create it" do
        it "should set :noaccess status" do
          FileUtils.expects(:mkdir_p).with("/path/to/dir", :mode => 644).raises(Errno::EACCES)
          subject.perform!.should == :noaccess
          subject.should be_noaccess
        end
      end
    end
    
    context "when unknown error raised while creating directory" do
      it "shouldn't create it and set :noaccess status" do
        FileUtils.expects(:mkdir_p).with("/path/to/dir", :mode => 644).raises(Exception)
        subject.perform!.should == :error
        subject.should be_error
      end
    end
    
    context "when directory can't been created" do
      it "shouldn't create it and set :error status" do
        FileUtils.expects(:mkdir_p).with("/path/to/dir", :mode => 644).returns(false)
        subject.perform!.should == :error
        subject.should be_error
      end
    end
  end
end

