module Wizard
  class Formula
    
    colorizers.merge!(
      :created  => :green,
      :exist    => :cyan,
      :noaccess => :red, 
    )
    
    def make_dir(dirname, options={})
      spell = Spells::MakeDir.new(dirname, options)
      spell.perform
      render(spell)
    end
    alias_method :dir, :make_dir
    alias_method :directory, :make_dir
    alias_method :mkdir, :make_dir
    alias_method :create_dir, :make_dir
    
  end # Formula

  module Spells
    class MakeDir < Base
    
      attr_reader :dirname, :chmod
      attr_status :created, :exist, :noaccess
    
      def initialize(dirname, options={})
        @dirname = dirname
        @chmod   = options[:mode]
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
      
      alias_method :to_s, :dirname
      
    end # MakeDir
  end # Spells
end # Wizard
