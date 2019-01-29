#!/usr/bin/env ruby

require 'erb'

template_file = ARGV[0]
destination_file = ARGV[1]

template = File.read(template_file)
rendered_template = ERB.new(template).result(binding)

File.open(destination_file, 'w') do |f|
  f.write(rendered_template)
end