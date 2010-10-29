require File.expand_path("../spec_helper", __FILE__)

describe Ryori::Makers do
  
end

describe Ryori::Makers::Base do
  subject do
    Ryori::Makers::Base
  end
  
  describe ".all_forced?" do
    it "should return false by default" do
      subject.should_not be_all_forced
    end
  end
  
  describe ".force_all!" do
    it "should set force mode for all makers" do
      subject.force_all!
      subject.should be_all_forced
    end
    
    after do
      subject.send(:class_variable_set, "@@force_all", false)
    end
  end
  
  describe "#force!" do
    it "should set force mode for current action" do
      base = subject.new
      base.force!
      base.instance_variable_get("@force").should == true
    end
  end
  
  describe "#force?" do
    context "when local force mode is enabled" do
      context "and global disabled" do
        it "should return true" do
          base = subject.new
          base.force!
          base.should be_forced
        end
      end
    end
    
    context "when local force mode is disabled" do
      context "and global disabled" do
        it "should return false" do
          base = subject.new
          base.should_not be_forced
        end
      end
      
      context "and global enabled" do
        it "should return true" do
          base = subject.new
          base.force_all!
          base.should be_forced
        end
      end
      
      after do
        subject.send(:class_variable_set, "@@force_all", false)
      end
    end
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
  
  describe ".attr_status" do
    before do
      klass = Class.new(subject)
      klass.attr_status :testing
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
      klass.attr_status :testing
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
