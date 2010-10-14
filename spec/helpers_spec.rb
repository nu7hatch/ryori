require "spec_helper"

describe "Ryori common helpers" do 
  subject { Ryori }
  
  it "should be able to colorize text" do 
    subject.colorize("foo", :red).should == "\e[0;31mfoo\e[0m"
    subject.colorize("bar", :red, true).should == "\e[1;31mbar\e[0m"
  end
  
  it "should be able to adjust given text to desired length" do 
    subject.adjust("foo", 20).should == "foo \e[0;30m................\e[0m"
    subject.adjust("foo", 25, '-').should == "foo \e[0;30m---------------------\e[0m"
  end
  
  it "should properly display colorized text on screen" do 
    Ryori::Helpers::COLORS.each do |color, code|
      [false, true].each do |bold|
        Ryori.expects(:print).with("\e[#{bold ? 1 : 0};#{code}m#{color.to_s}\n\e[0m")
        capture(:stdout) { Ryori.say!(color.to_s, color, bold) }
      end
    end
  end
  
end
