watch('app/assets/stylesheets/(.*)\.s[ac]ss') { |md| sass md[0], "public/stylesheets/#{md[1]}.css" }
watch('app/assets/javascripts/(.*)\.coffee') { |md| coffee md[0], "public/javascripts/#{md[1]}.js" }
watch('app/templates/(.*)\.hbs') { |md| handlebars md[0], "public/templates/#{md[1]}.js" }
watch('app/(.*)\.haml') { |md| haml md[0], "public/#{md[1]}.html" }

def sass(input, output)
  FileUtils.mkdir_p File.dirname output
  run "sass --compass #{input}:#{output}"
end

def coffee(input, output)
  output_dir = File.dirname output
  run "coffee --output #{output_dir} #{input}"
end

def handlebars(input, output)
  FileUtils.mkdir_p File.dirname output
  run "handlebars #{input} -f #{output}"
end

def haml(input, output)
  FileUtils.mkdir_p File.dirname output
  run "haml #{input} #{output}"
end

def run(command)
  puts command
  system command
end
