module Ryori
  # Common helpers used in various places by Ryori components... 
  module Helpers
    # List of available console colors. Each color have its "bold" version. 
    COLORS = {
      :black  => 30,
      :red    => 31,
      :green  => 32,
      :yellow => 33,
      :blue   => 34,
      :purple => 35,
      :cyan   => 36,
      :white  => 37,
    }
    
    # Display colorized output (no new line at the end).
    def say(text, color=nil, bold=false)
      print(color ? colorize(text, color, bold) : text)
    end
    
    # Writes given text to <tt>$stdout</tt>
    def print(*args)
      res = $stdout.write(*args)
      $stdout.flush
      return res
    end
    
    # Display colorized output. 
    def say!(text, color=nil, bold=false)
      say(text+"\n", color, bold)
    end
    
    # Colorize specified text with given color. 
    def colorize(text, color=:white, bold=false)
      color = COLORS[color] || COLORS[:white]
      return "\e[#{bold ? 1 : 0};#{color}m#{text}\e[0m"
    end
    alias :c :colorize
    
    # Display given text adjusted to the desired length.
    #
    #   adjust("This", 30, "-")
    #   adjust("is", 30, "-")
    #   adjust("SPARTA!", 30, "-")
    #
    # will produce:
    #
    #   This -------------------------
    #   is ---------------------------
    #   SPARTA! ----------------------
    def adjust(text, size=80, delim=".")
      delims = size-text.size
      delims > 0 ? text+" "+(c(delim*(delims-1), :black)) : text 
    end
    alias :a :adjust
  end # Helpers
end # Ryori
