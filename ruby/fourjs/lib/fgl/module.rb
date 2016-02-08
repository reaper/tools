require_relative "source.rb"

module Fgl
  class Module < Source
    attr_accessor :modules
    attr_reader :build_extension, :has_main

    def initialize file_path
      super(file_path)
      @modules = []
      @build_extension = ".42m"

      content = File.read(@file_path)
      content.scan(/import\sfgl\s(.*)/i).flatten.each do |import|
        module_file = File.join(File.dirname(@file_path), import.concat(".4gl"))
        if File.exists?(module_file)
          @modules << Module.new(module_file)
        end
      end

      @has_main = content.scan(/end\smain/i).flatten.any?
    end

    ## Get module dependencies
    def dependencies
      deps = []
      modules_without_main = @modules.delete_if { |m| m.has_main }
      deps << modules_without_main

      if modules_without_main.any?
        for mod in modules_without_main
          deps << mod.dependencies
        end
      end

      return deps.flatten
    end

    ## Compile module and its dependencies
    def compile
      for mod in @modules
        mod.compile
      end

      Dir.chdir File.dirname(@file_path)

      cmd = "fglcomp -M ".concat(@file_path)
      puts cmd
      system cmd
    end

    ## Get build file path
    def build_file_path
      "#{File.join(File.dirname(@file_path), File.basename(@file_path, File.extname(@file_path)).concat(@build_extension))}"
    end

  end
end
