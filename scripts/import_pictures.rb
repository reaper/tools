# Import pictures from a folder to another
# Author::  Pierre FILSTROFF (mailto:pfilstroff@gmail.com)

require 'pathname'
require 'ostruct'
require 'optparse'
require 'fileutils'
require 'RMagick'
require 'date'

include Magick

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-sSOURCE", "--source=SOURCE", "source") do |s|
    options[:source] = s
  end

  opts.on("-dDESTINATION", "--destination=DESTINATION", "destination") do |d|
    options[:destination] = d
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
end.parse!

options = OpenStruct.new options

# Check options
unless options.source
  puts "Missing argument: source"
  exit 0
end

unless options.destination
  puts "Missing argument: destination"
  exit 0
end


## Copy images from a source directory to a destination directory
# source_folder
# destination_folder
def copy_images_from_source_to_destination source_folder, destination_folder
  # Check existing folders
  unless File.exists?(destination_folder)
    destination_path = Pathname.new(destination_folder)
    destination_folder = File.join(destination_path.parent, destination_path.basename.to_s.gsub(/\W/, '_').upcase)

    unless File.exists?(destination_folder)
      FileUtils.mkdir destination_folder, verbose: true
    end
  end

  unless File.directory?(destination_folder)
    puts "#{destination_folder} isn't a directory"
    exit 0
  end

  unless File.exists?(source_folder)
    puts "#{source_folder} doesn't exists"
    exit 0
  end

  unless File.directory?(source_folder)
    puts "#{source_folder} isn't a directory"
    exit 0
  end

  source_file = Pathname.new(source_folder)
  destination_file = Pathname.new(destination_folder)

  # Getting destination files and sort them by modified time a second time
  destination_files = Dir.glob(File.join(destination_file.realpath, '*'))
  destination_files = destination_files.sort_by{ |f| File.mtime(f) }

  last_file = destination_files.last

  # Build a start index
  if last_file && File.exists?(last_file)
    last_file_basename = File.basename(last_file, File.extname(last_file))
    matches = last_file_basename.scan(/(\d*)$/)
    index = matches.flatten.reject! { |c| c.empty? }.first.to_i
  else
    index = -1
  end

  puts "\nLast file path: #{File.basename(last_file)}\n\n" if last_file && File.exist?(last_file)

  source_files = Dir.glob(File.join(source_file.realpath, '*'))
  source_files = source_files.sort_by{ |f| File.mtime(f) }
  ordered_source_files = []

  puts "\nAnalyzing pictures and checking for duplicates..." if source_files.any?
  for f in source_files
    file = Pathname.new(f)

    if file.directory?
      copy_images_from_source_to_destination file.realpath.to_s, File.join(destination_file.realpath.to_s, file.basename.to_s)
    else
      if %w(.png .jpg .jpeg .gif .bmp).include?(file.extname.to_s.downcase)
        image = Image.read(file.realpath).first

        for dest_file in Dir.glob(File.join(destination_file.realpath, '*'))
          dest_image = Image.read(dest_file).first

          begin
            diff_img, diff_metric = image.compare_channel(dest_image, Magick::MeanSquaredErrorMetric)
          rescue
            diff_metric = 1
          end

          if diff_metric == 0.0
            duplicate_img = dest_file
            break
          end
          diff_img.destroy!
          dest_image.destroy!
        end

        unless duplicate_img
          time = DateTime.parse(image.properties['date:modify'])

          ordered_source_files << [file, time]
        else
          puts "-> #{File.basename(f)} has a duplicate in the destination directory: #{File.basename(duplicate_img)}"
        end

        image.destroy!
      else
        puts "-> Cannot process #{File.basename(f)}: not an image"
      end
    end
  end

  puts "Copying pictures to #{destination_file.realpath}" if ordered_source_files.any?
  for f_list in ordered_source_files.sort_by {|l| l.last}
    file = f_list.first
    time = f_list.last

    final_index = index + 1
    final_file_basename = "#{destination_file.basename.to_s.gsub(/\W/, '_').upcase}_#{time.strftime('%Y-%m-%d')}_#{final_index}#{file.extname}"
    final_file_path = File.join(destination_file.realpath, final_file_basename)

    unless File.exists?(final_file_path)
      FileUtils.cp file.realpath, final_file_path, verbose: true, preserve: true
      File.utime(File.atime(final_file_path), time.to_time, final_file_path)
      index = final_index
    else
      puts "-> File #{final_file_path} already exists."
    end
  end
end

copy_images_from_source_to_destination options.source, options.destination
