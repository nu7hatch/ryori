require File.expand_path("../../spec_helper", __FILE__)

describe Ryori::Makers::FileMaker do
  subject do
    Ryori::Makers::FileMaker
  end
  
  describe "#initialize" do
    it "should set given filename" do
      subject.new("/path/to/file").filename.should == "/path/to/file"
    end
    
    context "given content" do
      it "should be set" do
        subject.new("/path/to/file", "hello world!").content.should == "hello world!"
      end
    end
    
    it "should set default chmod" do
      subject.new("/path/to/file").chmod.should == 644
    end
    
    context "given :mode option" do
      it "should set it" do
        subject.new("/path/to/file", nil, :mode => 755).chmod.should == 755
      end
    end
    
    context "given :force option" do
      it "should run in force mode" do
        subject.new("/path/to/file", nil, :force => true).should be_forced
      end
    end
  end
  
  describe "#perform!" do
    subject do
      Ryori::Makers::FileMaker.new("/path/to/file")
    end

    context "when given file exists" do
      subject do
        Ryori::Makers::FileMaker.new("/path/to/file", "testing")
      end

      context "and it content is identical as given one" do
        it "should set :identical status" do
          File.expects(:exist?).returns(true)
          File.expects(:read).with("/path/to/file").returns("testing")
          subject.perform!.should == :identical
          subject.should be_identical
        end
      end
      
      context "and it content is different than given one" do
        subject do
          Ryori::Makers::FileMaker.new("/path/to/file", "testing")
        end
        
        it "should set :conflict status" do
          File.expects(:exist?).returns(true)
          File.expects(:read).with("/path/to/file").returns("not-testing")
          subject.perform!.should == :conflict
          subject.should be_conflict
        end
        
        context "and force mode is on" do
          subject do
            Ryori::Makers::FileMaker.new("/path/to/file", "testing", :force => true)
          end
      
          it "should overwrite current file" do
            File.expects(:exist?).returns(true)
            File.expects(:read).with("/path/to/file").returns("not-testing")
            subject.expects(:create_file!).returns(true)
            subject.perform!.should == :updated
            subject.should be_updated
          end
        end
      end
    end
    
    context "when given directory doesn't exist" do
      context "and user have access to create it" do
        it "should set :created status" do
          File.expects(:open).with("/path/to/file", "w+").returns(true)
          FileUtils.expects(:chmod).with(644, "/path/to/file").returns(true)
          subject.perform!.should == :created
          subject.should be_created
        end
      end
      
      context "and user don't have access to create it" do
        it "should set :noaccess status" do
          File.expects(:open).with("/path/to/file", "w+").raises(Errno::EACCES)
          subject.perform!.should == :noaccess
          subject.should be_noaccess
        end
      end
    end
    
    context "when unknown error raised while creating file" do
      it "shouldn't create it and set :noaccess status" do
        File.expects(:open).with("/path/to/file", "w+").raises(Exception)
        subject.perform!.should == :error
        subject.should be_error
      end
    end
    
    context "when file can't be created or chmod not set" do
      it "shouldn't create it and set :error status" do
        File.expects(:open).with("/path/to/file", "w+").returns(false)
        subject.perform!.should == :error
        subject.should be_error
      end
    end
  end
end
