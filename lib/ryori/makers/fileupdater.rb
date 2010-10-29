module Ryori
  module Makers
    module FileUpdater < Base
    
      attr_reader :filename, :chmod, :content, :before, :after
      attr_status :updated, :noaccess
    
      def initialize(filename, content=nil, options={})
        @filename  = filename
        @content   = content 
        @chmod     = options[:mode] || 644
        @force     = options[:force]
        @before    = options[:before]
        @after     = options[:after]
      end
    
      def perform!
      
      end
      
    end # FileUpdater
  end # Makers
end # Ryori
