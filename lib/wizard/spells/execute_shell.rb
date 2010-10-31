module Wizard
  module Spells
    class ExecuteShell < Base
    
      attr_reader :command, :output
      attr_status :executed, :failed
      
      def initialize(command, options={})
        @command = command
        @output = nil
      end
    
      def perform
        return executed! if @output = `#{command} 2>&1` and $?.exitstatus == 0
        failed!
      rescue Object
        error!
      end
      
    end # CompileTemplate
  end # Spells
end # Wizard
