require 'wizard/spells/make_file'
require 'erb'

module Wizard
  module Spells
    class CompileTemplate < MakeFile
    
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
      
    end # CompileTemplate
  end # Spells
end # Wizard
