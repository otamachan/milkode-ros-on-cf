# -*- coding: utf-8 -*-
require 'milkode/cli'
require 'fileutils'

FileUtils.mkdir_p ENV['MILKODE_DEFAULT_DIR']
# Initialize database
CLI.start("init".split)
# Copy milkweb.yaml
IO.write(File.join(ENV['MILKODE_DEFAULT_DIR'],
                   'milkweb.yaml'),
         File.open('./milkweb.yaml') do |f|
           f.read.gsub(/\{ROSDISTRO\}/, ENV['ROSDISTRO'].capitalize)
         end
         )

