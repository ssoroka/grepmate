require 'rubygems'
begin
  gem 'syntax'
rescue LoadError
end
require 'yaml'
require 'enumerator'
require File.join(File.dirname(__FILE__), 'output', 'html')
require File.join(File.dirname(__FILE__), 'output', 'textmate')
require File.join(File.dirname(__FILE__), 'output', 'text')
require File.join(File.dirname(__FILE__), 'output', 'file_and_line')

class Grepmate
  attr_reader :params, :dirs, :query, :results
  CONFIG_FILE = File.expand_path("~/.grepmate")
  
  def initialize(params)
    @params = params

    load_config

    determine_directories_to_search
    determine_what_to_search_for

    find

    display
  end
  
  def gem_path
    `gem environment gemdir`.chomp
  end

  def gems_path
    File.join(gem_path, 'gems')
  end

  def rails_version
    `rails -v`.chomp.split(' ').last
  end

  def rails_path
    vendor_rails = "vendor/rails"

    if File.exist?(vendor_rails)
      vendor_rails
    else
      Dir["#{gems_path}/acti*-#{rails_version}"]
    end
  end
  
  def load_config
    if !File.exist?(CONFIG_FILE)
      # create
      safe_puts "Creating config file #{CONFIG_FILE}..."
      FileUtils.cp(File.expand_path(File.join(File.dirname(__FILE__), %w(.. config dot-grepmate))), CONFIG_FILE)
    end
    
    # load
    @config = YAML::load(File.read(CONFIG_FILE))
    # set output type
    @output = @config['default_output']
    %w(html text textmate file_and_line).each{|out_type|
      @output = out_type if params[out_type].value
    }
    # set default search directories
    unless params['dir'].values.any?
      params['dir'].values = @config['search_dirs']
    end
    
    # exclude extensions
    @excludes = (@config['exclude_file_extensions'] || []).map{|ext| "\.#{ext}$" }
    # path exclusions
    @excludes += (@config['exclude_from_path'] || [])
    
    @search_rails = params['rails'].given? ? params['rails'].value : @config['search_rails_source']
    @search_gems = params['gems'].given? ? params['gems'].value : @config['search_gems']
  end

  # use default dirs, param dirs, or files/dirs from STDIN
  def determine_directories_to_search
    if STDIN.tty?
      @dirs = if params['only_rails'].value || params['only_gems'].value
        [] 
      else
        params['dir'].values
      end
      @dirs += Array(rails_path) if params['only_rails'].value || params['rails'].value
      @dirs << gems_path if params['only_gems'].value || params['gems'].value
    else
      @dirs = []
      input = STDIN.read
    
      input.split("\n").each do |ln|
        if ln =~ /^([^:]*)/ # Assume everything to the first colon is a file name
          filename = File.expand_path($1)
          if File.exist?(filename) # But actually check that it is
            @dirs << filename
          end
        end
      end
    end
    @dirs.uniq!
    @dirs.map!{ |dir| File.exist?(dir) ? File.expand_path(dir) : nil }
    @dirs.compact!
  end

  def determine_what_to_search_for
    # funny bunny => 'funny' 'bunny'
    # 'funny bunny' => 'funny bunny'
    if params['regex'].value
      exp = params['what_to_search_for'].value.dup
      exp.gsub!(/^\//, '')
      exp.gsub!(/\/$/, '')
      @query = %("#{exp}")
      safe_puts "Searching for: /#{exp}/"
    else
      safe_puts "Searching for: #{params['what_to_search_for'].values.inspect}"
      @query = params['what_to_search_for'].values.map {|v| "\"#{v.gsub(/"/, '\\"')}\"" }.join(" ")
    end
  end

  def find
    @results = []
    if @dirs.any?
      paths = `find #{@dirs.join(' ')}`.split("\n").map{|sp| sp.gsub(' ', '\\ ')} # escape spaces in found files
      paths.delete_if { |path| @excludes.any?{ |exclude| path =~ /#{exclude}/i } }

      cmd = 'grep '
      cmd << '-i ' unless params['case'].value
      # 3 lines of context unless we're not displaying html, or we're counting
      cmd << '-C 3 ' if (@output == 'html' || @output == 'text') && !params['count'].value
      cmd << '-E ' if params['regex']

      # paths get too large for grep to handle, so limit the number it has to deal with at once.
      paths.each_slice(100) {|sub_paths|
        @results += `#{cmd} -n #{query} #{sub_paths.join(' ')}`.split("\n")
      }
    end
  end

  def display
    if @results.empty?
      safe_puts "Nothing found!"
      exit
    elsif params['count'].value
      puts "Matches: #{@results.size}"
      exit
    end

    output_class = case @output.to_s
    when 'html'
      Output::HTML
    when 'text'
      Output::Text
    when 'textmate'
      Output::Textmate
    when 'file_and_line'
      Output::FileAndLine
    end
    
    output_class.new(@results, @params).process
  end
  
  def safe_puts(msg)
    if STDOUT.tty?
      puts msg
    end
  end
end
