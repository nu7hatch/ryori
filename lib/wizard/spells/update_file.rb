require 'wizard/spells/make_file'

module Wizard
  module Spells
    class UpdateFile < MakeFile
    
      attr_reader :filename, :chmod, :content, :before, :after, :replace
      attr_status :missing
    
      def initialize(filename, content=nil, options={})
        super(filename, nil, options)

        @content   = content
        @before    = options[:before]
        @after     = options[:after]
        @replace   = options[:replace]
      end
    
      def perform
        return missing! unless File.exist?(filename)
        prepare_content and super
      rescue Object
        error!
      end
      
      def prepare_content
        if (before || after) && !replace
          old_content = File.read(filename)
          return @content += old_content if before == true
          return @content = old_content+@content if after == true
          
          (old_content = old_content.split(/$/)).each_with_index do |line, id|
            old_content[id] = [content, line].join("\n") if before && !after && line =~ before
            old_content[id] = [line, content].join("\n") if after && !before && line =~ after
          end
          
          @content = old_content.join
        elsif replace
          @content = File.read(filename).sub(replace, @content)
        end
      end
      
    end # UpdateFile
  end # Spells
end # Wizard
