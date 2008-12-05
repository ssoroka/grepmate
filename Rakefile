require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('grepmate', '1.0.0') do |p|
  p.description = 'Extremely fast search of rails projects or rails source for code, open in textmate or browser with html output'
  p.url = 'http://github.com/ssoroka/grepmate'
  p.author = 'Steven Soroka'
  p.email = 'ssoroka78@gmail.com'
  p.ignore_pattern = ["tmp/*"]
  p.development_dependencies = ['main']
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each{|f| load f }