module Ryori
  module Makers
    class Dirmaker < Base
    
      attr_reader :dirname
      attr_reader :chmod
    
      def initialize(dirname, chmod=644)
        @dirname = dirname
        @chmod   = chmod
      end
    
      def perform!
        
      end
      
    end # Dirmaker
  end # Makers
end # Ryori
