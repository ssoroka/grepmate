module Output
  class Text
    def initialize(grepmate)
      @grepmate = grepmate
    end
    
    def process
      puts @grepmate.results
    end
  end
end