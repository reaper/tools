require_relative "source.rb"

module Fgl
  class Form < Source
    attr_reader :build_extension

    def initialize file_path
      super(file_path)
      @build_extension = ".42f"
    end

    ## Compile form
    def compile
      Dir.chdir File.dirname(@file_path)

      cmd = "fglform -M ".concat(@file_path)
      puts cmd
      system cmd
    end

    ## Get build file path
    def build_file_path
      "#{File.basename(@file_path, File.extname(@file_path))}#{@build_extension}"
    end
  end
end
