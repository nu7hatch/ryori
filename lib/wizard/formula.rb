module Wizard
  class Formula
  
    include Helpers
  
    COLORIZERS = {
      :success => :green,
      :error   => :red,
    }
    
    def self.colorizers
      COLORIZERS
    end
  
    def render(spell)
      line = " "
      line += a(spell.to_s, console_width-spell.status.to_s.size-3) + " " 
      line += c(spell.status.to_s, self.class.colorizers[spell.status], true)
      say! line
    end
    
  end # Formula
end # Ryori
