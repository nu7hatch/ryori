module Ryori
  module Makers
  
    autoload :Dirmaker,  "ryori/makers/dirmaker"
    #autoload :Filemaker, "ryori/makers/filemaker"
    
    class Base
      
      include Helpers
      
      # Creates shortcuts for given statuses:
      #
      #   my_status! # => status!(:my_status)
      #   my_status? # => status?(:my_status)
      #
      def self.status(*statuses)
        statuses.each do |status|
          define_method("#{status}!".to_sym) { status!(status.to_sym) }
          define_method("#{status}?".to_sym) { status?(status.to_sym) }
          protected "#{status}!".to_sym
        end
      end
      
      # Shortcuts for the most commonly used statuses. We are creating 
      # <tt>success</tt> and <tt>error</tt> shortcuts by default. 
      status :success, :error
      
      # Returns status of currently performed operation. 
      def status
        @status
      end
      
      # Returns +true+ when actual status equals the given one.
      #
      #   status!(:success)
      #   status?(:success) # => true
      #   status?(:error)   # => false
      #
      def status?(status)
        self.status == status.to_sym
      end
      
      protected

      # Set given status for actual operation.
      #
      #   status!(:success)
      #   status!(:error)
      #
      def status!(status)
        @status = status.to_sym
      end
      
    end # Base
  end # Makers
end # Ryori
