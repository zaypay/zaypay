require 'fileutils'
zaypay_config_source = File.expand_path(File.dirname(__FILE__) + '/example_config.yml')
zaypay_config_target = File.expand_path(File.dirname(__FILE__) + '/../../../config/zaypay.yml')

if File.exists? zaypay_config_target
  puts "You've already got config/zaypay.yml. We're keeping that."
else
  puts "Copying an example config-file to config/zaypay.yml"
  File.copy zaypay_config_source, zaypay_config_target
end