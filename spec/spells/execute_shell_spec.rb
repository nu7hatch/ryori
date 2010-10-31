require File.expand_path("../../spec_helper", __FILE__)

describe Wizard::Spells::ExecuteShell do
  subject do
    Wizard::Spells::ExecuteShell
  end
  
  describe "#initialize" do
    it "should set given command" do
      subject.new("echo 'test'").command.should == "echo 'test'"
    end
  end
  
  describe "#perform" do
    context "when given command is valid" do
      subject do
        Wizard::Spells::ExecuteShell.new("echo 'test'")
      end
      
      it "should execute command and set :executed status" do
        spell = subject
        spell.perform == :executed
        spell.should be_executed
      end
      
      it "should set it output to instance variable" do
        spell = subject
        spell.perform
        spell.output.should == "test\n"
      end
    end
    
    context "when given command causes errors" do
      subject do
        Wizard::Spells::ExecuteShell.new("some-error")
      end
      
      it "should execute command and set :executed status" do
        spell = subject
        spell.expects(:failed!).raises(Exception)
        spell.perform == :error
        spell.should be_error
      end
    end
    
    context "when given command can't be executed" do
      subject do
        Wizard::Spells::ExecuteShell.new("no-such-command")
      end
      
      it "should execute command and set :executed status" do
        spell = subject
        spell.perform == :failed
        spell.should be_failed
      end
    end 
  end
end
