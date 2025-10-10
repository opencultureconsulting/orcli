# render script - html-form
require 'gtx'
require 'fileutils'

# Load the GTX template
template = "#{source}/html-form.gtx"
gtx = GTX.load_file template

# Render the file for the main command
save "#{target}/index.html", gtx.parse(command)

# Render a file for each subcommand
command.deep_commands.reject(&:private).each do |subcommand|
  save "#{target}/#{subcommand.full_name}.html", gtx.parse(subcommand)
end

# Copy JS and CSS to target directory
FileUtils.cp "#{source}/style.css", "#{target}/style.css"
puts "saved #{target}/style.css"
FileUtils.cp "#{source}/script.js", "#{target}/script.js"
puts "saved #{target}/script.js"
