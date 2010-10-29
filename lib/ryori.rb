require "fileutils"
require "erb"

module Ryori

  autoload :Makers,    "ryori/makers"
  autoload :Helpers,   "ryori/helpers"
  autoload :Generator, "ryori/generator"
  
  extend Helpers
  
end # Ryori
