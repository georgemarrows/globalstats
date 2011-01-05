require 'graph'

WIDTH = 200
HEIGHT = 200

xindex = (1990..2009).to_a
XMIN = xindex.min
XMAX = xindex.max
XLENGTH = xindex.size
         
YMIN = 0
YMAX = 30

TICK_SIZE = 3

XAXIS = Axis.new(WIDTH, XMIN, XMAX, :x)
YAXIS = Axis.new(HEIGHT, YMIN, YMAX, :y)

data = DataSeries.new(XAXIS, YAXIS)
graph = Graph.new(XAXIS, YAXIS)

def graphpos(countryno, graphno)

  return 4.5 * WIDTH + 1.5 * WIDTH * graphno, 2 * HEIGHT * countryno

end

raw = File.read("aids_rawdata.csv")

x = raw.split(%r{[\r\n]+})[1..-1].grep(/^\^/).map_with_index do |line, lno|
  country_data = line.split(",")
  [country_data[0], *country_data[1..XLENGTH].map {|d| d.to_f}]
end.sort_by {|xx| xx[0]}

graphs = x.map_with_index do |xx, lno|
country = xx[0]
country_data = xx[1..XLENGTH]

graphx, graphy = graphpos(lno, 1)
#{data.draw(xindex, country_data, "prevalence", :labels => :startend, :label_formatter => proc {|x, i| x.to_s + "%"}) }
%{
<g transform="scale(1,-1) translate(#{graphx}, #{-graphy-500})  ">
<g transform='translate(0,#{HEIGHT + 10}) scale(1,-1)'><text class='title' x='#{0}' y='0'>#{country[1..-1]}</text></g>
#{graph.draw_background()}
#{graph.draw_gridlines(:y, 10)}
#{XAXIS.draw(xindex, :ticks_every => 5)}
#{YAXIS.draw(country_data, :ticks_every => :min_max_only, :label_formatter => proc {|x| x.to_s + "%"}) }
#{data.draw(xindex, country_data, "prevalence", :labels => :none)}
</g>
}	
end.join("\n")



raw = File.read("aids_newinfections.csv")

x = raw.split(%r{[\r\n]+})[1..-1].grep(/^\^/).map_with_index do |line, lno|

	country_data = line.split(",")
	[country_data[0], *country_data[1..XLENGTH].map {|d| d.to_f}]
end.sort_by {|xx| xx[0]}


graphs += x.map_with_index do |xx, lno|
country = xx[0]
country_data = xx[1..XLENGTH]

yaxis = Axis.new(HEIGHT, 0, country_data.max, :y)

data = DataSeries.new(XAXIS, yaxis)
graph = Graph.new(XAXIS, yaxis)

graphx, graphy = graphpos(lno, 2)
#{data.draw(xindex, country_data, "newinfections", :labels => :startend, :label_formatter => proc {|x,i| ((x/1000.0).round()).to_s + "k"})}

%{
<g transform="scale(1,-1) translate(#{graphx}, #{-graphy-500})  ">

#{graph.draw_background()}
#{XAXIS.draw(xindex, :ticks_every => 5)} 
#{yaxis.draw(country_data, :ticks_every => :min_max_only, :label_formatter => proc {|x| ((x/1000.0).round()).to_s + "k"})}
#{data.draw(xindex, country_data, "newinfections", :labels => :none)}
</g>
}
	
end.join("\n")





art_xlength=6
xindex = (2004..2009).to_a

raw = File.read("aids_art_cd4_200.csv")

x = raw.split(%r{[\r\n]+})[1..-1].grep(/^\^/).map_with_index do |line, lno|

	country_data = line.split(",")
	[country_data[0], *country_data[1..-1].map {|d| d.to_f}]
end.sort_by {|xx| xx[0]}


graphs += x.map_with_index do |xx, lno|
country = xx[0]
country_data = xx[1..-1]

xaxis = Axis.new(WIDTH, 2004, 2009, :x)
yaxis = Axis.new(HEIGHT, 0, 100, :y)

data = DataSeries.new(xaxis, yaxis)
graph = Graph.new(xaxis, yaxis)

graphx, graphy = graphpos(lno, 3)

#{data.draw(xindex, country_data, "art", :labels => :startend, :label_formatter => proc {|x, i| x.round().to_s + "%"}) }

%{
<g transform="scale(1,-1) translate(#{graphx}, #{-graphy-500})  ">
#{graph.draw_background()}
#{graph.draw_gridlines(:y, 20)}
#{xaxis.draw(xindex, :ticks_every => 1)} 
#{yaxis.draw(country_data, :ticks_every => :min_max_only, :label_formatter => proc {|x| x.round().to_s + "%"})}
#{data.draw(xindex, country_data, "art", :labels => :none)}
</g>
}	
end.join("\n")


















puts <<END
<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="#{2000}" height="#{2000}" version="1.1"
     xmlns="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"     >
     <defs>
       <style type="text/css"><![CDATA[
         .background {
           /*fill: rgb(240,240,240);*/
           fill: rgb(255,255,255);
           stroke: rgb(150,150,150);
           stroke-width: 1pt;
         }
       
         line.axis {
	   stroke: rgb(0,0,0);
           stroke-width: 1pt;      
         }

         line.gridlines {
/*	   stroke: rgb(255,255,255); */
           stroke: rgb(150,150,150);
           stroke-width: 1pt;      
         }

         .data {
           stroke-width: 2pt;
           stroke: rgb(200,0,0);
           fill: none;
         }
         .newinfections {
           stroke: rgb(0,200,0);
         }
         .art {
           stroke: rgb(0,0,200);
         }
         text {
           fill: rgb(50,50,50);
           font-family: "Helvetica Neue LT Std", "Futura Bk";
           font-size: 16pt;
         }
         text.title {
           font-size: 30pt;
           text-anchor: start;
         }
         text {
           text-anchor: end;              
         }
         text.right {
           text-anchor: start;  
         }
         text.xlabel.min {
           text-anchor: start;
         }
         text.xlabel.max {
           text-anchor: end;
         }
         
       ]]></style>
     </defs> 
     <g transform="scale(0.5,0.5)">  
     #{graphs}
     </g>

</svg>
END



