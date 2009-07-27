module Output
  class HTML
    TEMP_FILE = File.expand_path(File.join(ENV['TMPDIR'], %w(grepmate.html)))
    
    def initialize(grepmate)
      @grepmate = grepmate
    end
    
    def determine_javascript_highlight_text
      @grepmate.params['what_to_search_for'].values.map {|v| "highlightSearchTerms('#{v.gsub(/'/, "\\'").gsub(/:/, "\\:")}', false)" }.join(";")
    end

    def process
      syntax_installed = true
      begin
        require 'syntax/convertors/html'
      rescue LoadError
        syntax_installed = false
      end

      html = '<html><head>'
      html << <<-CSS
  <style type="text/css">body { background-color: #EEEEEE; } pre {
  display: inline; } .ruby { font-family: Monaco; font-size: 10pt;
  background-color: white } .ruby .normal {} .ruby .comment { color:
  #005; font-style: italic; } .ruby .keyword { color: #A00; font-weight:
  bold; } .ruby .method { color: #077; } .ruby .class { color: #074; }
  .ruby .module { color: #050; } .ruby .punct { color: #447; font-weight:
  bold; } .ruby .symbol { color: #099; } .ruby .string { color: #944;
  background: #FFE; } .ruby .char { color: #F07; } .ruby .ident { color:
  #004; } .ruby .constant { color: #07F; } .ruby .regex { color: #B66;
  background: #FEF; } .ruby .number { color: #F99; } .ruby .attribute {
  color: #7BB; } .ruby .global { color: #7FB; } .ruby .expr { color:
  #227; } .ruby .escape { color: #277; } .ruby .highlight {
  background-color: yellow; font-weight: 900; } td.lineno { text-align:
  right; font-family: Monaco; font-size: 9pt; padding-right: 10px; }
  td.filename { padding-top: 35px; font-family: Monaco; font-size: 14pt;
  }</style>

  <script type="text/javascript">
  // http://www.nsftools.com/misc/SearchAndHighlight.htm

  function doHighlight(bodyText,searchTerm,highlightStartTag,highlightEndTag)
  {if((!highlightStartTag)||(!highlightEndTag)){highlightStartTag="<font style='color:blue; background-color:yellow;'>";highlightEndTag="</font>";}
  var newText="";var i=-1;var lcSearchTerm=searchTerm.toLowerCase();var lcBodyText=bodyText.toLowerCase();while(bodyText.length>0){i=lcBodyText.indexOf(lcSearchTerm,i+1);if(i<0){newText+=bodyText;bodyText="";}else{if(bodyText.lastIndexOf(">",i)>=bodyText.lastIndexOf("<",i)){if(lcBodyText.lastIndexOf("/script>",i)>=lcBodyText.lastIndexOf("<script",i)){newText+=bodyText.substring(0,i)+highlightStartTag+bodyText.substr(i,searchTerm.length)+highlightEndTag;bodyText=bodyText.substr(i+searchTerm.length);lcBodyText=bodyText.toLowerCase();i=-1;}}}}
  return newText;}
  function highlightSearchTerms(searchText,treatAsPhrase,warnOnFailure,highlightStartTag,highlightEndTag)
  {if(treatAsPhrase){searchArray=[searchText];}else{searchArray=searchText.split(" ");}
  if(!document.body||typeof(document.body.innerHTML)=="undefined"){if(warnOnFailure){alert("Sorry, for some reason the text of this page is unavailable. Searching will not work.");}
  return false;}
  var bodyText=document.body.innerHTML;for(var i=0;i<searchArray.length;i++){bodyText=doHighlight(bodyText,searchArray[i],highlightStartTag,highlightEndTag);}
  document.body.innerHTML=bodyText;return true;}</script></script>
    CSS

      # some searches can return stupid-huge result sets.  Javascript will likely freeze or crash the browser in those cases.
      if @grepmate.results.size < 1000
        html << "</head><body onLoad=\"#{determine_javascript_highlight_text}\">"
      else
        html << "</head><body>"
      end

      syntax_converter = (syntax_installed ? Syntax::Convertors::HTML.for_syntax("ruby") : nil)
      html << '<pre>sudo gem install syntax</pre> to get syntax highlighting<br><br>' unless syntax_installed

      html << '<table cellspacing="0" cellpadding="2">'

      last_file = ''
      separator = false

      html << @grepmate.results.map{ |line|
        if line == '--'
          separator = true
          ''
        elsif line =~ /^(.+?)-(\d+)-(.*)$/ || line =~ /^(.+?):(\d+):(.*)$/
          file = $1
          line = $2
          context = $3

          file_group = ''

          if file == last_file
            file_group << "<tr><td class=\"lineno\">...</td><td></td></tr>" if separator
          else
            parts = file.split(/\//)
            path = ''
            file_group << "<tr><td colspan=\"2\" class=\"filename\">"
            parts.each do |part|
              path << "/#{part}"
              file_group << "/" unless part.equal?(parts.first)
              if part.equal?(parts.last)
                file_group << "<a href=\"txmt://open?url=file://#{file}\">#{part}</a>"
              else
                file_group << "<a href=\"file:/#{path}\">#{part}</a>"
              end
            end
            file_group << "</td></tr>\n"
          end

          separator = false
          last_file = file

          file_group << "<tr><td class=\"lineno\"><a href=\"txmt://open?url=file://#{file}&line=#{line}\">#{line}</a></td>"

          converted = begin
            syntax_converter ? syntax_converter.convert(context =~ /^(.+?)\s*$/ ? $1 : context) : context
          rescue Exception => e
            "TOKENIZING ERROR: #{context} <!-- \n#{e.message}\n#{e.backtrace.join("\n")}\n -->"
          end
          file_group << "<td class=\"ruby\">#{converted}</td></tr>\n"

          file_group
        end
      }.join

      html << '</table></body></html>'

      begin
        FileUtils.touch(TEMP_FILE)
      rescue Errno::EACCES => e
        puts %(

        Looks like there's a permission error for the file #{TEMP_FILE}.  The grepmate gem expects to have write access to this file.

        To fix, please do:
          sudo chmod 0666 #{TEMP_FILE}
          
        )
        raise e
      end
      File.open(TEMP_FILE, 'w') { |f| f.write(html) }

      system("open #{TEMP_FILE}")
  
    end
  end
end