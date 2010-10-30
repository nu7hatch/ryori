require "erb"

module Ryori
  module Makers
    class FileCompiler < FileMaker
    
      attr_reader :template
    
      def initialize(filename, template, options={})
        @template  = template
        super(filename, nil, options)
      end
    
      def perform
        @content = ERB.new(File.read(template)).result(binding) and super
      rescue Object
        error!
      end
      
    end # FileUpdater
  end # Makers
end # Ryori
