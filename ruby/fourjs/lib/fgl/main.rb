require_relative "module.rb"

module Fgl
  class Main < Module
    attr_reader :link_extension

    def initialize file_path
      super(file_path)
      @link_extension = ".42r"
    end

    ## Get link file path
    def link_file_path
      "#{File.join(File.dirname(@file_path), File.basename(@file_path, File.extname(@file_path)).concat(@link_extension))}"
    end

    ## Link main genero program
    def link
      Dir.chdir File.dirname(@file_path)

      cmd = "fgllink -o #{self.link_file_path} #{self.build_file_path} #{self.dependencies.any? ? self.dependencies.map(&:build_file_path).uniq.join(" ") : nil}"
      puts cmd
      system cmd
    end
  end
end
