require File.expand_path("../spec_helper", __FILE__)

describe Ryori::Makers do
  
end

describe Ryori::Makers::Base do
  subject do
    Ryori::Makers::Base
  end
  
  describe "#status" do
    it "should be nil by default" do
      subject.new.status.should == nil
    end
    
    it "should return actual status" do
      base = subject.new
      base.instance_variable_set("@status", :test)
      base.status.should == :test
    end
  end
  
  it "#status! should set actual status" do
    base = subject.new
    base.send(:status!, :test)
    base.status.should == :test
  end
  
  describe "#status?" do
    before do
      @base = subject.new
      @base.send(:status!, :test)
    end

    it "should return true when given status is the same as actual" do
      @base.should be_status(:test)
    end
    
    it "should return false when given status is different than actual" do
      @base.should_not be_status(:invalid)
    end
  end
  
  describe ".status" do
    before do
      klass = Class.new(subject)
      klass.status :testing
      @test = klass.new
    end
    
    it "should define shortcut for setting given status" do
      @test.should respond_to(:testing!)
    end
    
    it "should define shortcut for checking given status" do
      @test.should respond_to(:testing?)
    end
  end
  
  describe "shortcuts created by .status" do
    before do
      klass = Class.new(subject)
      klass.status :testing
      @test = klass.new
    end
    
    context "for setting status" do
      it "should work properly" do
        @test.send :testing!
        @test.should be_status(:testing)
      end
    end
    
    context "for checking status" do
      it "should work properly" do
        @test.send :testing!
        @test.should be_testing
        @test.send :status!, :another
        @test.should_not be_testing
      end
    end
  end
end
