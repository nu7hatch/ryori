require 'wizard/spells/make_file'
require 'erb'

module Wizard
  module Spells
    class CompileTemplate < MakeFile
    
      attr_reader :template
    
      def initialize(filename, template, options={})
        super(filename, nil, options)
        @template  = template
      end
    
      def perform_with_template_compilation
        @content = ERB.new(File.read(template)).result(binding)
        perform_without_template_compilation
      rescue Object
        error!
      end
      
      alias_method :perform_without_template_compilation, :perform
      alias_method :perform, :perform_with_template_compilation
      
    end # CompileTemplate
  end # Spells
end # Wizard
