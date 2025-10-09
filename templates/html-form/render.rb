# render script - html-form
require 'gtx'
require 'fileutils'

# Load the GTX template
template = "#{source}/html-form.gtx"
gtx = GTX.load_file template

# Render the file
save "#{target}/index.html", gtx.parse(command)

# Copy JS and CSS to target directory
FileUtils.cp "#{source}/style.css", "#{target}/style.css"
puts "saved #{target}/style.css"
FileUtils.cp "#{source}/script.js", "#{target}/script.js"
puts "saved #{target}/script.js"
