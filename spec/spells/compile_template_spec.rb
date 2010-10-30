require File.expand_path("../../spec_helper", __FILE__)

describe Wizard::Spells::CompileTemplate do
  subject do
    Wizard::Spells::CompileTemplate
  end
  
  describe "#initialize" do
    it "should set given filename" do
      subject.new("/path/to/file", "/path/to/tpl").filename.should == "/path/to/file"
    end
    
    context "given template name" do
      it "should be set" do
        subject.new("/path/to/file", "/path/to/tpl").template.should == "/path/to/tpl"
      end
    end
    
    it "should set default chmod" do
      subject.new("/path/to/file", "/path/to/tpl").chmod.should == 644
    end
    
    context "given :mode option" do
      it "should set it" do
        subject.new("/path/to/file", "/path/to/tpl", :mode => 755).chmod.should == 755
      end
    end
    
    context "given :force option" do
      it "should run in force mode" do
        subject.new("/path/to/file", "/path/to/tpl", :force => true).should be_forced
      end
    end
  end
  
  context "#perform" do
    subject do
      Wizard::Spells::CompileTemplate.new("/path/to/file", "/path/to/tpl")
    end
    
    context "when given template causes errors" do
      it "should set :error state" do
        File.expects(:read).with("/path/to/tpl").raises(Exception)
        maker = subject
        maker.perform.should == :error
        maker.should be_error
      end
    end
    
    context "when given template is ok" do
      it "should run FileMaker on given file" do
        File.expects(:read).with("/path/to/tpl").returns("<%='test'%>")
        ERB.expects(:new).returns(stub(:result => false))
        maker = subject
        maker.perform.should == false
        maker.content.should == false
      end
    end
  end
end
