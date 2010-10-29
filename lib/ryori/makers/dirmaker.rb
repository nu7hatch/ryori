module Ryori
  module Makers
    class Dirmaker < Base
    
      attr_reader :dirname, :chmod
      attr_status :created, :exist, :noaccess
    
      def initialize(dirname, chmod=644)
        @dirname = dirname
        @chmod   = chmod
      end
    
      def perform!
        return exist!   if File.exist?(dirname)
        return created! if FileUtils.mkdir_p(dirname, :mode => chmod) == dirname
        error!
      rescue Errno::EACCES
        noaccess!
      rescue Object
        error!
      end
      
    end # Dirmaker
  end # Makers
end # Ryori
