# -*- coding: utf-8 -*-
require 'milkode/cli'
require 'fileutils'
require 'open-uri'
require 'yaml'

black_list = ['.pgm', '.gif', '.png', '.bmp', '.ppm', '.jpg', '.tif', '.svg',
              '.bag', '.pcd',
              '.dae', '.stl', '.ply', '.mesh', '.wrl', '.skp',
              '.zip', '.gz', '.jar', '.bz2',
              '.blend',
              '.vec',
              '.mpg', '.mpeg', '.avi', '.wav', '.mp4', '.m4',
              '.ps', '.pdf', '.eps', '.dvi',
              '.odp', 'ppt', '.pptx', '.xls', '.docx', '.doc',
              '.db',
              '.bin', '.so', '.exe', '.dll', '.dylib', '.lib', '.a', '.o',
              '.0', '.pos','.mdl']
max_size = 0.2*1024.0*1024.0 # 0.2M
rosdistro = ENV['ROSDISTRO']

# Add pacakges
dst_dir = File.join(ENV['MILKODE_DEFAULT_DIR'], 'packages/git')
FileUtils.mkdir_p dst_dir
rosdistro_url = "https://raw.githubusercontent.com/ros/rosdistro/master/#{rosdistro}/distribution.yaml"
distribution = YAML::load(open(rosdistro_url){|f| f.read})
distribution['repositories'].each do |repo_name, repo|
  next if !repo.include?('release')
  packages = repo['release'].include?('packages') ? repo['release']['packages'] : [repo_name]
  for package in packages do
    repo_url = repo['release']['url']
    next if !repo_url.start_with?('https://github.com')
    repo_dir = File.join(dst_dir, package)
    system("git clone --depth 1 #{repo_url} #{repo_dir} -b release/#{rosdistro}/#{package}")
    FileUtils.rm_rf File.join(repo_dir, '.git')
    Dir.glob("#{repo_dir}/**/*") do |f|
      if File.file?(f) then
        size = File.size(f)
        if black_list.include?(File.extname(f).downcase) then
          puts f
          File.open(f, 'w') {|fout| fout.write("Removed because of the file type")}
        elsif size > max_size then
          puts f
          File.open(f, 'w') {|fout| fout.write("Removed because of the size #{size}")}
        end
      end
    end
    CLI.start(['add', repo_dir])
    FileUtils.rm_rf repo_dir
  end
end
