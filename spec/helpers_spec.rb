require File.expand_path("../spec_helper", __FILE__)

describe Wizard::Helpers do
  subject do
    Wizard
  end
  
  context "#say!" do
    Wizard::Helpers::COLORS.each do |color, code|
      [false, true].each do |bold|
        it "should properly display #{bold ? "bold and" : ""}#{color.to_s} text on screen" do 
          capture { Wizard.say!(color.to_s, color, bold) }
          last_stdout.should == "\e[#{bold ? 1 : 0};#{code}m#{color.to_s}\n\e[0m"
        end
      end
    end
  end
  
  describe "#print" do
    it "should properly print given text to stdout" do
      capture { subject.print "This is SPARTA!" }
      last_stdout.should == "This is SPARTA!"
    end
  end
  
  describe "#colorize" do
    it "should colorize given text" do 
      subject.colorize("foo", :red).should == "\e[0;31mfoo\e[0m"
      subject.colorize("bar", :red, true).should == "\e[1;31mbar\e[0m"
    end
  end
  
  describe "#console_width" do
    it "should return actual console width" do
      # tested manualy...
      subject.console_width
    end
  end
  
  describe "#adjust" do
    context "when size given" do
      it "should adjust text to given size" do
        subject.adjust("foo", 8).should == "foo \e[0;30m....\e[0m"
        subject.adjust("foo", 8, '-').should == "foo \e[0;30m----\e[0m"
      end
    end
    
    context "when no size given" do
      it "should adjust text to console size" do
        subject.expects(:console_width).returns(10)
        subject.adjust("foo").should == "foo \e[0;30m......\e[0m"
      end
    end
  end
end
