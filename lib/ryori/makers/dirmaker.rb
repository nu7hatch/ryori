module Ryori
  module Makers
    class DirMaker < Base
    
      attr_reader :dirname, :chmod
      attr_status :created, :exist, :noaccess
    
      def initialize(dirname, options={})
        @dirname = dirname
        @chmod   = options[:mode] || 644
      end
    
      def perform
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
