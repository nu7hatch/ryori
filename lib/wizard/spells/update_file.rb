require 'wizard/spells/make_file'

module Wizard
  class Formula
    
    colorizers.merge!(
      :missing => :red
    )
    
    def update_file(filename, content=nil, options={})
      spell = Spells::UpdateFile.new(filename, content, options)
      spell.perform
      render(spell)
    end
    alias_method :update, :update_file
  
    def append_to_file(filename, content, options={})
      update_file(filename, content, options.merge(:before => :EOF))
    end
    alias_method :append, :append_to_file
    alias_method :append_to, :append_to_file
    
    def prepend_to_file(filename, content, options={})
      update_file(filename, content, options.merge(:after => :BOF))
    end
    alias_method :prepend, :prepend_to_file
    alias_method :prepend_to, :prepend_to_file
    
    def replace_in_file(filename, content, replace, options={})
      update_file(filename, content, options.merge(:replace => replace))
    end
    alias_method :replace, :replace_in_file
    alias_method :replace_content, :replace_in_file
  
  end # Formula

  module Spells
    class UpdateFile < MakeFile
    
      attr_reader :filename, :chmod, :content, :before, :after, :replace
      attr_status :missing
    
      def initialize(filename, content=nil, options={})
        super(filename, nil, options)

        @content = content
        @before  = options[:before]
        @after   = options[:after]
        @replace = options[:replace]
      end
    
      def perform_with_content_update
        if File.exist?(filename)
          force! and rebuild_content and perform_without_content_update
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
      
      # Build new content based on original one, including specified update
      # directives. All directives can't be mixed, which mean that only 
      # one update can ba applied on the file at one time. If none directive 
      # is specified, then whole file content will be replaced with specified 
      # in constructor.
      def rebuild_content
        if (before || after) && !replace
          content = File.read(filename)
          
          return @content = [@content, content].join("\n") if after == :BOF
          return @content = [content, @content].join("\n") if before == :EOF
          
          content = content.sub(/\r\n/, "\n").sub(/\r/, "\n").split(/\n/)
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
