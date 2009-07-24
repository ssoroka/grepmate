module Output
  class Text
    def initialize(input, params)
      @input = input
    end
    
    def process
      puts @input
    end
  end
end