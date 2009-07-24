require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Grepmate" do
  before(:each) do
    @orig_pwd = Dir.pwd
    Dir.chdir(File.expand_path(File.join(File.dirname(__FILE__), '..')))
  end
  
  after(:each) do
    # change back
    Dir.chdir @orig_pwd
  end
  
  describe 'bin/grepmate' do
    it "should search project" do
      output = `bin/grepmate -c "module Output"`.split("\n").compact.last
      output.should =~ /Matches\: (\d+)/
      output.scan(/Matches\: (\d+)/).flatten.first.to_i.should >= 6
    end
    
    it "should behave when piped STDIN files" do
      `echo LICENSE | bin/grepmate -c "Steven Soroka"`.chomp.should == 'Matches: 1'
    end
    # 
    # it "should search gems" do
    #   # dev most likely has "main" gem installed, since it's a requirement, search for the words "gem install main" in the readme.
    #   `bin/grepmate -G -f "gem install main" 2> /dev/null`.grep(/main-[\d\.]+\/README/).should_not be_nil
    # end
    # 
    # it "should search rails" do
    #   # changelog is unlikely to change or go missing, since it's historical.
    #   `bin/grepmate -R -f "Fixed that validate_length_of lost :on option when :within was specified" 2> /dev/null`.grep(/CHANGELOG/).should_not be_nil
    # end
    
    it "should support regular expressions" do
      # from LICENSE: this will match:  Steven Soroka
      `echo LICENSE | bin/grepmate -c -e "even .oro.a"`.chomp.should == 'Matches: 1'
    end
    
    describe 'output' do
      it "should output text" do
        puts `bin/grepmate --text 'Steven Soroka'`
      end
      
      it "should output html" do
        # `bin/grepmate --html 'Steven Soroka'`
        params = mock(:params)
        params.should_receive(:[]).with('html').and_return(mock(:html, :value => true))
        params.should_receive(:[]).with('text').and_return(mock(:text, :value => false))
        params.should_receive(:[]).with('textmate').and_return(mock(:textmate, :value => false))
        params.should_receive(:[]).with('file_and_line').and_return(mock(:file_and_line, :value => false))
        params.should_receive(:[]).with('dir').and_return(mock(:dir, :values => ['bin', 'config', 'lib', 'spec'], :values= => nil))
        params.should_receive(:[]).with('rails').and_return(mock(:rails, :given? => nil, :value => nil))
        params.should_receive(:[]).with('gems').and_return(mock(:gems, :given? => nil, :value => nil))
        params.should_receive(:[]).with('only_rails').and_return(mock(:only_rails, :value => nil))
        params.should_receive(:[]).with('only_gems').and_return(mock(:only_gems, :value => nil))
        params.should_receive(:[]).with('regex').and_return(mock(:regex, :value => nil))
        params.should_receive(:[]).with('case').and_return(mock(:case, :value => nil))
        params.should_receive(:[]).with('count').and_return(mock(:case, :value => nil))
        params.should_receive(:[]).with('what_to_search_for').and_return(mock(:what_to_search_for, :values => ["Steven Soroka"]))
        
        Object.should_receive(:system).with("open ")
        Grepmate.new(params)
      end
      
      it "should output textmate commands"
      it "should output file and line number commands" do
        `bin/grepmate -f "module Output"`.split("\n").first.should =~ %r(lib/output/file_and_line\.rb:1)
      end
    end
  end
end
