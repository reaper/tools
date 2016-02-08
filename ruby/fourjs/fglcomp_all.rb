#!/usr/bin/env ruby
# Compile sources in a folder and try to link them
# Author::  Pierre FILSTROFF (mailto:pfilstroff@gmail.com)

require_relative "lib/fgl/main.rb"
require_relative "lib/fgl/form.rb"

## Process folder and compile all genero source files
def process_folder folder, mains, forms
  for file in Dir.glob(File.join(folder, "*"))
    if File.directory?(file)
      process_folder file, mains, forms
    else
      file_name = File.basename(file)
      file_ext = File.extname(file_name)

      if file_ext.eql?(".4gl")
        file_content = File.read(file)

        if file_content.scan(/end\smain/i).flatten.any?
          mains << Fgl::Main.new(file)
        end
      elsif file_ext.eql?(".per")
        forms << Fgl::Form.new(file)
      end
    end
  end

end


mains = []
forms = []

process_folder(Dir.pwd, mains, forms)

for form in forms
  form.compile
end

for main in mains
  main.compile
  main.link
end
