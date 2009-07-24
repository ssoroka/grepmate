module Output
  class FileAndLine
    def initialize(grepmate)
      @grepmate = grepmate
    end
    
    def process
      @grepmate.results.each{|line|
        if line
          puts line.split(':')[0..1].join(':')
        else
          puts line
        end
      }
    end
  end
end