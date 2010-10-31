require File.expand_path("../../spec_helper", __FILE__)

describe Wizard::Spells::UpdateFile do
  subject do
    Wizard::Spells::UpdateFile
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
    
    context "given :before option" do
      it "should set it" do
        subject.new("/path/to/file", nil, :before => /test/).before.should == /test/
      end
    end
    
    context "given :after option" do
      it "should set it" do
        subject.new("/path/to/file", nil, :after => /test/).after.should == /test/
      end
    end
    
    context "given :replace option" do
      it "should set it" do
        subject.new("/path/to/file", nil, :replace => /test/).replace.should == /test/
      end
    end
  end
  
  describe "#perform" do
    context "when specified file doesn't exist" do
      context "and given content only" do
        subject do
          Wizard::Spells::UpdateFile.new("/path/to/file", "testing")
        end
      
        it "should create this file" do
          spell = subject
          File.expects(:exist?).with("/path/to/file").returns(false)
          spell.expects(:perform_without_content_update).returns(:created)
          spell.perform.should == :created
        end
      end
      
      context "and given :before option" do
        subject do
          Wizard::Spells::UpdateFile.new("/path/to/file", "testing", :before => /test/)
        end
      
        it "should create this file" do
          spell = subject
          File.expects(:exist?).with("/path/to/file").returns(false)
          spell.perform.should == :missing
        end
      end
      
      context "and given :after option" do
        subject do
          Wizard::Spells::UpdateFile.new("/path/to/file", "testing", :after => /test/)
        end
      
        it "should create this file" do
          spell = subject
          File.expects(:exist?).with("/path/to/file").returns(false)
          spell.perform.should == :missing
        end
      end
      
      context "and given :replace option" do
        subject do
          Wizard::Spells::UpdateFile.new("/path/to/file", "testing", :replace => /test/)
        end
      
        it "should create this file" do
          spell = subject
          File.expects(:exist?).with("/path/to/file").returns(false)
          spell.perform.should == :missing
        end
      end
    end

    context "when some error has been raised" do
      subject do
        Wizard::Spells::UpdateFile.new("/path/to/file", "testing")
      end
    
      it "should set :error status" do
        spell = subject
        File.expects(:exist?).with("/path/to/file").raises(Exception)
        spell.perform.should == :error
      end
    end
    
    context "when specified file exists" do
      context "and given content only" do
        subject do
          Wizard::Spells::UpdateFile.new("/path/to/file", "testing")
        end
        
        it "should replace file content" do
          spell = subject
          File.expects(:exist?).with("/path/to/file").returns(true)
          spell.expects(:perform_without_content_update).returns(:updated)
          spell.perform.should == :updated
          spell.content.should == "testing"
        end
      end
      
      context "and given :replace option" do
        subject do
          Wizard::Spells::UpdateFile.new("/path/to/file", "Sparta", :replace => /persia/i)
        end
        
        it "should replace file content" do
          spell = subject
          File.expects(:exist?).with("/path/to/file").returns(true)
          File.expects(:read).with("/path/to/file").returns("This is Persia!")
          spell.expects(:perform_without_content_update).returns(:updated)
          spell.perform.should == :updated
          spell.content.should == "This is Sparta!"
        end
      end
      
      context "and given :after option" do
        subject do
          Wizard::Spells::UpdateFile.new("/path/to/file", "not", :after => /^is$/i)
        end
        
        it "should put given content after matching line" do
          spell = subject
          File.expects(:exist?).with("/path/to/file").returns(true)
          File.expects(:read).with("/path/to/file").returns("This\nis\nPersia!")
          spell.expects(:perform_without_content_update).returns(:updated)
          spell.perform.should == :updated
          spell.content.should == "This\nis\nnot\nPersia!"
        end
      end
      
      context "and given :after is :BOF" do
        subject do
          Wizard::Spells::UpdateFile.new("/path/to/file", "This", :after => :BOF)
        end
        
        it "should put given content at the begining of file" do
          spell = subject
          File.expects(:exist?).with("/path/to/file").returns(true)
          File.expects(:read).with("/path/to/file").returns("is\nSparta!")
          spell.expects(:perform_without_content_update).returns(:updated)
          spell.perform.should == :updated
          spell.content.should == "This\nis\nSparta!"
        end
      end
      
      context "and given :before option" do
        subject do
          Wizard::Spells::UpdateFile.new("/path/to/file", "not", :before => /^persia/i)
        end
        
        it "should put given content before matching line" do
          spell = subject
          File.expects(:exist?).with("/path/to/file").returns(true)
          File.expects(:read).with("/path/to/file").returns("This\nis\nPersia!")
          spell.expects(:perform_without_content_update).returns(:updated)
          spell.perform.should == :updated
          spell.content.should == "This\nis\nnot\nPersia!"
        end
      end
      
      context "and given :before is :EOF" do
        subject do
          Wizard::Spells::UpdateFile.new("/path/to/file", "Sparta!", :before => :EOF)
        end
        
        it "should put given content at the end of file" do
          spell = subject
          File.expects(:exist?).with("/path/to/file").returns(true)
          File.expects(:read).with("/path/to/file").returns("This\nis")
          spell.expects(:perform_without_content_update).returns(:updated)
          spell.perform.should == :updated
          spell.content.should == "This\nis\nSparta!"
        end
      end
    end
  end
end
