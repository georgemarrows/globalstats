require 'graph'
require 'datazub'

TICK_SIZE = 3

def make_graph(data, codes, gdp)
	
	country_map = {
"Bolivia (Plurinational State of)" => "Bolivia",
"Brunei Darussalam" => "Brunei",
"Central African Republic" => "Central African Rep.",
"Congo" => "Congo Rep.",
"C?te d'Ivoire" => "Cote d'Ivoire",
"Czech Republic" => "Czech Rep.",
"Democratic People's Republic of Korea" => "Korea Dem. Rep.",
"Democratic Republic of the Congo" => "Congo Dem. Rep.",
"Dominican Republic" => "Dominican Rep.",
"Iran (Islamic Republic of)" => "Iran",
"Lao People's Democratic Republic" => "Laos",
"Libyan Arab Jamahiriya" => "Libya",
"Occupied Palestinian Territory" => "Palestine???",
"Republic of Korea" => "Korea Rep.",
"Republic of Moldova" => "Moldova",
"Russian Federation" => "Russia",
"Slovakia" => "Slovak Republic",
"Syrian Arab Republic" => "Syria",
"The former Yugoslav Republic of Macedonia" => "Macedonia FYR",
"United Republic of Tanzania" => "Tanzania",
"United States of America" => "United States",
"Venezuela (Bolivarian Republic of)" => "Venezuela",
"Viet Nam" => "Vietnam",
"Yemen" => "Yemen Rep."
}
	
	xaxis = Axis.new(800, 1000, 4000, :x)
	yaxis = Axis.new(200,  2, 5, :y)
	
	graph = Graph.new(xaxis, yaxis)
	svg = graph.draw_background() +
              graph.draw_gridlines(:x, 1000) +
              graph.draw_gridlines(:y, 1) +
              xaxis.draw([1000,2000,3000,4000], :all_labels=>true) +
              yaxis.draw([2,3,4,5], :all_labels=>true, :label_formatter => proc{|y| ["100", "1k", "10k", "100k"][y-2] })
      
        code_extr = proc do |val| 
      	      
        	return (codes[val[0].upcase] || "").downcase 
        end
      
        hist = Histogram.new(xaxis, yaxis)
        svg += hist.draw(data, 
        	         proc{ |d| d[1]},
        	         proc do |d| 
        	         	 country = d[0] 
        	         	 country = country_map[country] if !gdp[country]
        	         	 if gdp[country]
        	         	 	 #STDERR.puts "#{d[0]} - #{country} - #{gdp[country]}"
        	         	 	 Math.log10(gdp[country])
        	         	 else
        	         	 	 STDERR.puts "#{d[0]} - #{country}"
        	         	 	 0
        	         	 end
        	         end,
        	         code_extr
        	         
        	         )
        
        css = <<END
         line.gridlines, .ticks {
           stroke: rgb(210,210,210);
           stroke-width: 1px;      
         }       
         .background {
           fill: rgb(226,225,215);
           stroke: rgb(210,210,210);
           stroke-width: 1px;
         }
         text {
           fill: rgb(50,50,50);
           font-family: "Helvetica Neue LT Std", "Futura Bk";
           font-size: 11pt;         
         }
         text.xlabel.min { text-anchor: start; }
         text.xlabel.mid { text-anchor: middle; } 
         text.xlabel.max { text-anchor: end; }
         text.ylabel     { text-anchor: end; }            
END
        	
	[svg, css]	
end

raw = File.read("FoodConsumptionNutrients_en.csv")


data = raw.split(%r{[\r\n]+})[3..-1].map do |line|
  country_data = line.split(",")
  [country_data[1], country_data[-1].to_f] 
end

raw2 = File.read("country_code_map.csv")
	
codes = {}
raw2.split(%r{[\r\n]+}).each do |line|
   name, code = *line.split(";")
   codes[name] = code
end

def make_css(data, codes)

	data.each do |c, d|
		if !codes[c.upcase] 		
			puts c	
		end
	end
	
	
	def mkblue(v)
		t = (v - 2500) / 1500   	#  0 < t < 1
		[255*(1-t), 255*(1-t), 255]
	end
	
	def mkred(v)
		t = (2500 - v) / 1000   	#  0 < t < 1
		[255, 255*(1-t), 255*(1-t)]
	end
	
	css =
	data.map do |c, d|
		next if !codes[c.upcase] 		
		code = codes[c.upcase]
		red, green, blue = if d > 2500
			mkblue(d)
		else 
			mkred(d)
		end
		".#{code.downcase} { fill: rgb(#{red.round},#{green.round},#{blue.round}) }"
	end.join("\n") 	
	
	css +=
		"circle.cd { stroke: black; stroke-width:3px}" +
		"circle.id { stroke: black; stroke-width:3px}" +
		"circle.us { stroke: black; stroke-width:3px}"
end

gdp = DataZub.from_csv("indicatorgapmindergdp_per_capita_ppp.csv",1).
                cselect(0,-4).  # 2006
                transform(1, :to_f)

print gdp.cselect(-1).to_array.max


graph, css = make_graph(data, codes, gdp.to_hash)
css += make_css(data, codes)



svg = File.read("BlankMap-World6.svg")

svg.sub!(%r{/\*\* STYLES HERE \*\*/}, css)
#svg.sub!(%r{<!-- ADD -->}, %{<g transform="translate(200,0) scale(1,-1)">} + graph + %{</g>})

File.open("out.svg", "w") do |f| f.write(svg) end


svg = File.read("graph-template.svg")

svg.sub!(%r{/\*\* STYLES HERE \*\*/}, css)
svg.sub!(%r{<!-- ADD -->}, %{<g transform="translate(100,300) scale(1,-1)">} + graph + %{</g>})

File.open("out2.svg", "w") do |f| f.write(svg) end


