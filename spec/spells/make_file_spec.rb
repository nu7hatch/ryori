require File.expand_path("../../spec_helper", __FILE__)

describe Wizard::Spells::MakeFile do
  subject do
    Wizard::Spells::MakeFile
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
  
  describe "#perform" do
    subject do
      Wizard::Spells::MakeFile.new("/path/to/file")
    end

    context "when specified file exists" do
      subject do
        Wizard::Spells::MakeFile.new("/path/to/file", "testing")
      end

      context "and it content is identical as given one" do
        it "should set :identical status" do
          File.expects(:exist?).returns(true)
          File.expects(:read).with("/path/to/file").returns("testing")
          spell = subject
          spell.perform.should == :identical
          spell.should be_identical
        end
      end
      
      context "and it content is different than given one" do
        subject do
          Wizard::Spells::MakeFile.new("/path/to/file", "testing")
        end
        
        it "should set :conflict status" do
          File.expects(:exist?).returns(true)
          File.expects(:read).with("/path/to/file").returns("not-testing")
          spell = subject
          spell.perform.should == :conflict
          spell.should be_conflict
        end
        
        context "and force mode is on" do
          subject do
            Wizard::Spells::MakeFile.new("/path/to/file", "testing", :force => true)
          end
      
          it "should overwrite current file" do
            File.expects(:exist?).returns(true)
            File.expects(:read).with("/path/to/file").returns("not-testing")
            spell = subject
            spell.expects(:create_file!).returns(true)
            spell.perform.should == :updated
            spell.should be_updated
          end
        end
      end
    end
    
    context "when specified file doesn't exist" do
      context "and user have access to create it" do
        it "should set :created status" do
          File.expects(:open).with("/path/to/file", "w+").returns(true)
          FileUtils.expects(:chmod).with(644, "/path/to/file").returns(true)
          spell = subject
          spell.perform.should == :created
          spell.should be_created
        end
      end
      
      context "and user don't have access to create it" do
        it "should set :noaccess status" do
          File.expects(:open).with("/path/to/file", "w+").raises(Errno::EACCES)
          spell = subject
          spell.perform.should == :noaccess
          spell.should be_noaccess
        end
      end
    end
    
    context "when unknown error raised while creating file" do
      it "shouldn't create it and set :noaccess status" do
        File.expects(:open).with("/path/to/file", "w+").raises(Exception)
        spell = subject
        spell.perform.should == :error
        spell.should be_error
      end
    end
    
    context "when file can't be created or chmod not set" do
      it "shouldn't create it and set :error status" do
        File.expects(:open).with("/path/to/file", "w+").returns(false)
        spell = subject
        spell.perform.should == :error
        spell.should be_error
      end
    end
  end
end
