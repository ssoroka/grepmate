require 'rubygems' unless defined?(Gem)
gem 'rspec'
require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'grepmate'

class Param
  def initialize(v)
    @v = v
  end
  
  def value
    @v
  end

  def values
    Array(@v)
  end
  
  def values=(values)
    @v = values
  end
  
  def given?
    !!@v
  end
end

class Params
  def initialize(options)
    @options = options
  end
  
  def [](key)
    Param.new(@options[key])
  end
end

Spec::Runner.configure do |config|
  
end
