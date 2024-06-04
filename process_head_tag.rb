# ARVG[0] = DIRECTORY
# ARGV[1] = TARGET (antora or daps) 
# ARGV[2] = DOMAIN (OPTIONAL)
# e.g. ruby process_head_tag.rb docs/ antora
# e.g. ruby process_head_tag.rb docs/ daps https://example.com

for_antora = ARGV[1]=="antora" ? true : false

Dir.glob(["#{ARGV[0].chomp("/")}/**/*.md", "#{ARGV[0].chomp("/")}/**/*.mdx"]) do |file|
  # Ignore partial files
  if file.split("/")[-1].start_with?("_")
    next
  end

  process_head_tag(file, for_antora)

end

BEGIN {
  # Antora: only removes <head> tag and its contents
  # Other: remove <head> tag and move its contents into a docfile, <file>-docinfo.html
  def process_head_tag(file, for_antora)
    new_file = []
    new_docinfo_file = []
    docinfo_filename = file.sub(/\.md[x]*$/,"-docinfo.html")
    docinfo_enabler = %{:docinfo: private-head
}
    parsing_head_tag = false
    
    File.foreach(file).with_index do |line, line_num|
      if parsing_head_tag
        if line.strip.include?("</head>")
          parsing_head_tag = false
          File.write("#{docinfo_filename}", new_docinfo_file.join) if !for_antora
        elsif !for_antora
          if line.strip.include?('rel="canonical"')
            domain = !ARGV[2].nil? ? ARGV[2].chomp("/") : "NEW_BASEURL"
            new_line = line.sub(/href=".*.com/, "href=\"#{domain}")
            new_docinfo_file << new_line
          else
            new_docinfo_file << line.strip
          end
        end
      else
        if line.strip.include?("<head>")
          new_file << docinfo_enabler if !for_antora
          parsing_head_tag = true
        else
          new_file << line
        end
      end
    end

    File.write("#{file}", new_file.join)
  end
}
