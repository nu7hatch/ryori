module Ryori
  module Makers
    class Dirmaker < Base
    
      attr_reader :dirname, :chmod
      attr_status :exist
    
      def initialize(dirname, chmod=644)
        @dirname = dirname
        @chmod   = chmod
      end
    
      def perform!
        
      end
      
    end # Dirmaker
  end # Makers
end # Ryori
