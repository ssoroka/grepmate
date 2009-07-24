module Output
  class FileAndLine
    def initialize(input, params)
      @input = input
    end
    
    def process
      @input.each{|line|
        if line
          puts line.split(':')[0..1].join(':')
        else
          puts line
        end
      }
    end
  end
end