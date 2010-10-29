module Ryori
  module Makers
    class FileMaker < Base
    
      attr_reader :filename, :chmod, :content
      attr_status :created, :noaccess, :identical, :conflict, :updated
    
      def initialize(filename, content=nil, options={})
        @filename  = filename
        @content   = content 
        @chmod     = options[:mode] || 644
        
        force! if options[:force]
      end
    
      def perform!
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
        File.open(filename, "w+") {|f| f.write(content) if content } and
        FileUtils.chmod(chmod, filename)
      end
      
      # Returns +true+ when current file already exists and have the same 
      # content as given in initializer.  
      def identical_content?
        File.read(filename) == content
      end
      
    end # Filemaker
  end # Makers
end # Ryori
