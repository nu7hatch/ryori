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
    
    context "when specified template causes errors" do
      it "should set :error state" do
        File.expects(:read).with("/path/to/tpl").raises(Exception)
        spell = subject
        spell.perform.should == :error
        spell.should be_error
      end
    end
    
    context "when specified template is ok" do
      it "should compile it and invoke make_file" do
        File.expects(:read).with("/path/to/tpl").returns("<%='test'%>")
        spell = subject
        spell.expects(:perform_without_template_compilation).returns(:created)
        spell.perform.should == :created
        spell.content.should == 'test'
      end
    end
  end
end
