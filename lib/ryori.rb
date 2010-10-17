require "fileutils"
require "erb"

module Ryori
  autoload :Helpers,      "ryori/helpers"
  autoload :RawGenerator, "ryori/generators"
  autoload :Generator,    "ryori/generators"

  extend Helpers
end # Ryori
