require "spec_helper"

describe "Ryori helpers" do
  subject { Ryori }
  
  it "should properly print given text to stdout" do
    capture { subject.print "This is SPARTA!" }
    last_stdout.should == "This is SPARTA!"
  end
  
  it "should colorize given text" do 
    subject.colorize("foo", :red).should == "\e[0;31mfoo\e[0m"
    subject.colorize("bar", :red, true).should == "\e[1;31mbar\e[0m"
  end
  
  it "should adjust text to given size" do
    subject.adjust("foo", 8).should == "foo \e[0;30m....\e[0m"
    subject.adjust("foo", 8, '-').should == "foo \e[0;30m----\e[0m"
  end
  
  it "should display colorized text on screen" do 
    Ryori::Helpers::COLORS.each do |color, code|
      [false, true].each do |bold|
        capture { Ryori.say!(color.to_s, color, bold) }
        last_stdout.should == "\e[#{bold ? 1 : 0};#{code}m#{color.to_s}\n\e[0m"
      end
    end
  end
end
