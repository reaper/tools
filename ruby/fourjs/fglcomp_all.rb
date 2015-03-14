#!/usr/bin/env ruby
# Compile sources in a folder and try to link them
# Author::  Pierre FILSTROFF (mailto:pfilstroff@gmail.com)

current_path = Dir.pwd
libs = []

for file in Dir.glob(File.join(current_path, "*"))
  file_name = File.basename(file)
  file_ext = File.extname(file_name)

  if file_ext.eql?(".4gl")
    system "fglcomp ".concat(file_name)

    main_file = file if File.read(file).scan(/main/i).flatten.any?
    libs << file
  elsif file_ext.eql?(".per")
    system "fglform ".concat(file_name)
  end
end

if main_file
  system "fgllink -o #{File.basename(main_file, File.extname(main_file))} #{libs.map {|l| File.basename(l) }.join(" ")}"
end
