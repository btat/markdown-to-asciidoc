Dir.glob(["#{ARGV[0].chomp("/")}/**/*.md", "#{ARGV[0].chomp("/")}/**/*.mdx"]) do |file|
  # Ignore partial files
  if file.split("/")[-1].start_with?("_")
    next
  end

  file_incorrect_initial_header = %x[ grep -nrm 1 "^#" #{file} ]

  if !file_incorrect_initial_header.empty?
    if file_incorrect_initial_header.split(":").last.start_with?(/[#]{3,} /)
      puts file + ":" + file_incorrect_initial_header
    end
  end
end