module Wizard
  class Formula
    
    colorizers.merge!(
      :created   => :green,
      :noaccess  => :red,
      :identical => :cyan,
      :conflict  => :yellow,
      :updated   => :green,
      :skipped   => :yellow
    )
    
    def make_file(filename, content=nil, options={})
      spell = Spells::MakeFile.new(filename, content, options)
      spell.perform
      render(spell)
    end
    alias_method :file, :make_file
    alias_method :mkfile, :make_file
    alias_method :create_file, :make_file
    
  end # Formula

  module Spells
    class MakeFile < Base
    
      attr_reader :filename, :chmod, :content
      attr_status :created, :noaccess, :identical, :conflict, :updated, :skipped
    
      def initialize(filename, content=nil, options={})
        @filename = filename
        @content  = content 
        @chmod    = options[:mode]
        
        force! if options[:force]
      end
    
      def perform
        if File.exist?(filename)
          return identical! if identical_content?
          return status     if conflict! and !forced?
        end
        return conflict? ? updated! : created! if create_file!
        error!
      rescue Errno::EACCES
        noaccess!
      rescue Object
        error!
      end
      
      # Create current performed file, write its content and set proper chmod. 
      def create_file!
        if File.open(filename, "w+") {|f| f.write(content) if content }
          FileUtils.chmod(chmod, filename) if chmod
          return true
        end
      end
      
      # Returns +true+ when current file already exists and have the same 
      # content as given in initializer.  
      def identical_content?
        File.read(filename) == content
      end
      
      alias_method :to_s, :filename
      
    end # MakeFile
  end # Spells
end # Wizard
