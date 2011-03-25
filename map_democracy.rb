raw = File.readlines("world-audit-democracy.txt")

data = []
div = 0
raw.each do |line|
	line.chomp!
	
	if line.match(/\d/)
		div = Integer(line)
	else
		data << [line, div]
	end
end

raw2 = File.read("country_code_map.csv")

codes = {}
raw2.split(%r{[\r\n]+}).each do |line|
  name, code = *line.split(";")
  codes[name] = code
end


data.each do |c, d|
	if !codes[c.upcase] 		
	  puts c	
        end
end

colours = {1 => "rgb(0,127,68)",
	   2 => "rgb(10,178,100)",
	   3 => "rgb(82,195,136)",
           4 => "rgb(153,217,179)"}


css =
data.map do |c, d|
	next if !codes[c.upcase] 		
	code = codes[c.upcase]

	".#{code.downcase} { fill: #{colours[d]} }"
end.join("\n")

svg = File.read("BlankMap-World6.svg")

svg.sub!(%r{/\*\* STYLES HERE \*\*/}, css)
File.open("out.svg", "w") do |f| f.write(svg) end
