module Output
  class Textmate
    def initialize(input, params)
      @input = input
    end
    
    def process
      print "Found #{input.size} matches.  "
      if input.size > 20
        puts  "Display? [Y/n]..."
        exit if $stdin.gets.chomp.downcase == 'n'
      end

      input.each { |f|
        file, line = f.split(':')
        system("mate #{'-w ' if params['wait'].value}-l #{line} #{file}")
      }
    end
  end
end