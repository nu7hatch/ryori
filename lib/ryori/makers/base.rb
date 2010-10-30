module Ryori
  module Makers
    class Base

      include Helpers

      class << self
        # Should all actions be performed in force mode?
        def all_forced?
          defined?(@@force_all) and !!@@force_all
        end
        
        # Set force mode for all apps. 
        def force_all!
          @@force_all = true
        end
        
        # Creates shortcuts for given statuses:
        #
        #   attr_status :my_status
        #
        # will produce methods:
        #
        #   my_status! # => status!(:my_status)
        #   my_status? # => status?(:my_status)
        #
        def attr_status(*statuses)
          statuses.each do |status|
            define_method("#{status}!".to_sym) { status!(status.to_sym) }
            define_method("#{status}?".to_sym) { status?(status.to_sym) }
            protected "#{status}!".to_sym
          end
        end
      end
      
      # Shortcuts for the most commonly used statuses. We are creating 
      # <tt>success</tt> and <tt>error</tt> shortcuts by default. 
      attr_status :success, :error
      
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
      
      # Should be forced performing of current action?
      def forced?
        @force || self.class.all_forced?
      end
      
      # See Ryori::Makers::Base.force_all! for details.
      def force_all!
        self.class.force_all!
      end
      
      # Set force mode for current action.
      def force!
        @force = true
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
