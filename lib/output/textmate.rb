module Output
  class Textmate
    def initialize(grepmate)
      @grepmate = grepmate
    end
    
    def process
      print "Found #{@grepmate.results.size} matches.  "
      if @grepmate.results.size > 20
        puts  "Display? [Y/n]..."
        exit if $stdin.gets.chomp.downcase == 'n'
      else
        puts ''
      end

      @grepmate.results.each { |f|
        file, line = f.split(':')
        system("mate #{'-w ' if @grepmate.params['wait'].value}-l #{line} #{file}")
      }
    end
  end
end