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
    
      def perform_with_content_update
        if File.exist?(filename)
          force! and build_content and perform_without_content_update
        elsif content && !before && !after && !replace
          perform_without_content_update
        else
          missing!
        end
      rescue Object
        error!
      end
      
      alias_method :perform_without_content_update, :perform
      alias_method :perform, :perform_with_content_update
      
      def build_content
        if (before || after) && !replace
          content = File.read(filename)
          
          return @content = [@content, content].join("\n") if after == :BOF
          return @content = [content, @content].join("\n") if before == :EOF
          
          content = content.sub(/\r/, "").split(/\r?\n/)
          content.each_with_index do |line, id|
            content[id] = [@content, line].join("\n") if !after && before && line =~ before
            content[id] = [line, @content].join("\n") if !before && after && line =~ after
          end
          
          @content = content.join("\n")
        elsif replace
          @content = File.read(filename).sub(replace, @content)
        else
          @content
        end
      end
      
    end # UpdateFile
  end # Spells
end # Wizard
