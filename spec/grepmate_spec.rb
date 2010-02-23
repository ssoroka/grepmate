require File.expand_path(File.join(File.dirname(__FILE__),  'spec_helper'))

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
        result = `bin/grepmate --text 'Steven Soroka'`
        # spec/grepmate_spec.rb:22:      `echo LICENSE | bin/grepmate -c "Steven Soroka"`.chomp.should == 'Matches: 1'
        # spec/grepmate_spec.rb:36:      # from LICENSE: this will match:  Steven Soroka
        # spec/grepmate_spec.rb:42:        puts `bin/grepmate --text 'Steven Soroka'`
        # spec/grepmate_spec.rb:46:        # `bin/grepmate --html 'Steven Soroka'`
        # spec/grepmate_spec.rb:61:        params.(blah blah blah blah blah blah blah blah blah blah)s => ["Steven Soroka"]))
        result.should =~ /grepmate_spec/
      end
      
      it "should output html" do
        # `bin/grepmate --html 'Steven Soroka'`
        params = mock(:params)
        params.should_receive(:[]).with('html').any_number_of_times.and_return(mock(:html, :value => true))
        params.should_receive(:[]).with('text').any_number_of_times.and_return(mock(:text, :value => false))
        params.should_receive(:[]).with('textmate').any_number_of_times.and_return(mock(:textmate, :value => false))
        params.should_receive(:[]).with('file_and_line').any_number_of_times.and_return(mock(:file_and_line, :value => false))
        params.should_receive(:[]).with('dir').any_number_of_times.and_return(mock(:dir, :values => ['bin', 'config', 'lib', 'spec'], :values= => nil))
        params.should_receive(:[]).with('rails').any_number_of_times.and_return(mock(:rails, :given? => nil, :value => nil))
        params.should_receive(:[]).with('gems').any_number_of_times.and_return(mock(:gems, :given? => nil, :value => nil))
        params.should_receive(:[]).with('only_rails').any_number_of_times.and_return(mock(:only_rails, :value => nil))
        params.should_receive(:[]).with('only_gems').any_number_of_times.and_return(mock(:only_gems, :value => nil))
        params.should_receive(:[]).with('regex').any_number_of_times.and_return(mock(:regex, :value => nil))
        params.should_receive(:[]).with('case').any_number_of_times.and_return(mock(:case, :value => nil))
        params.should_receive(:[]).with('count').any_number_of_times.and_return(mock(:count, :value => nil))
        params.should_receive(:[]).with('verbose').any_number_of_times.and_return(mock(:verbose, :value => nil))
        params.should_receive(:[]).with('what_to_search_for').any_number_of_times.and_return(mock(:what_to_search_for, :values => ["Steven Soroka"]))
        
        grepmate = Grepmate.new(params)
        # hijack the output class so that it doesn't send the system() call.
        output_class = Output::HTML.new(grepmate)
        output_class.should_receive(:system).with("open #{output_class.instance_variable_get('@temp_file')}")
        
        Output::HTML.stub!(:new).and_return(output_class)
        
        grepmate.find
        grepmate.display
      end
      
      it "should output textmate commands" do
        # `bin/grepmate --textmate 'Steven Soroka'`
        params = mock(:params)
        params.should_receive(:[]).with('html').any_number_of_times.and_return(mock(:html, :value => false))
        params.should_receive(:[]).with('text').any_number_of_times.and_return(mock(:text, :value => false))
        params.should_receive(:[]).with('textmate').any_number_of_times.and_return(mock(:textmate, :value => true))
        params.should_receive(:[]).with('file_and_line').any_number_of_times.and_return(mock(:file_and_line, :value => false))
        params.should_receive(:[]).with('dir').any_number_of_times.and_return(mock(:dir, :values => ['bin', 'config', 'lib', 'spec'], :values= => nil))
        params.should_receive(:[]).with('rails').any_number_of_times.and_return(mock(:rails, :given? => nil, :value => nil))
        params.should_receive(:[]).with('gems').any_number_of_times.and_return(mock(:gems, :given? => nil, :value => nil))
        params.should_receive(:[]).with('only_rails').any_number_of_times.and_return(mock(:only_rails, :value => nil))
        params.should_receive(:[]).with('only_gems').any_number_of_times.and_return(mock(:only_gems, :value => nil))
        params.should_receive(:[]).with('regex').any_number_of_times.and_return(mock(:regex, :value => nil))
        params.should_receive(:[]).with('case').any_number_of_times.and_return(mock(:case, :value => nil))
        params.should_receive(:[]).with('count').any_number_of_times.and_return(mock(:count, :value => nil))
        params.should_receive(:[]).with('verbose').any_number_of_times.and_return(mock(:verbose, :value => nil))
        params.should_receive(:[]).with('wait').any_number_of_times.and_return(mock(:wait, :value => true))
        params.should_receive(:[]).with('what_to_search_for').any_number_of_times.and_return(mock(:what_to_search_for, :values => ["Steven Soroka"]))
        
        grepmate = Grepmate.new(params)
        # hijack the output class so that it doesn't send the system() call.
        output_class = Output::Textmate.new(grepmate)
        output_class.should_receive(:system).any_number_of_times # .with("mate -w blah blah"). I'm not going to try to guess all the finds.
        output_class.stub!(:print) # I don't want to see the output.
        output_class.stub!(:puts) # I don't want to see the output.
        
        Output::Textmate.stub!(:new).and_return(output_class)
        
        grepmate.find
        grepmate.display
      end
      
      it "should output file and line number commands" do
        `bin/grepmate -f "module Output"`.split("\n").first.should =~ %r(lib/output/file_and_line\.rb:1)
      end
    end
  end

  it "result_objects" do
    grepmate = Grepmate.new(Params.new('what_to_search_for' => 'Steven Soroka', 'text' => true, 'dir' => '.'))
    grepmate.find
    grepmate.result_objects.size.should > 10
  end

  it "should find 'gem install main' from the main gem that's hopefully installed" do
    grepmate = Grepmate.new(Params.new('what_to_search_for' => 'gem install main', 'text' => true, 'only_gems' => true, 'dir' => '.'))
    grepmate.find
    grepmate.result_objects.size.should > 0
    grepmate.result_objects.any?{|r| r[:file] =~ /README/ }.should be_true
  end
end
