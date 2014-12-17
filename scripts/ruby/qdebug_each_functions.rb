# Import pictures from a folder to another
# Author::  Pierre FILSTROFF (mailto:pfilstroff@gmail.com)

require 'optparse'
require 'ostruct'
require 'pathname'

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: qdebug_each_functions.rb [options]"

  opts.on("-fFILE", "--file=FILE", "file") do |f|
    options[:file] = f
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
end
optparse.parse!

options = OpenStruct.new options

if options.file
  file = Pathname.new options.file
  content = file.read
  modified_content = content.gsub(/(.*\:\:.*\(.*\).*)\s*\{/, '\\&
  qDebug() << \'\\1\'
')
  file.write(modified_content)
else
  puts optparse
end
