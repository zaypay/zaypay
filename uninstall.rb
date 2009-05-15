require 'fileutils'
zaypay_config_target = File.expand_path(File.dirname(__FILE__) + '/../../../config/zaypay.yml')

if File.exists? zaypay_config_target
  puts "Should we clean up config/zaypay.yml? [y/N]"
  FileUtils.rm zaypay_config_target if gets.downcase['y']
end