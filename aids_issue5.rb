require 'graph'

WIDTH = 100
HEIGHT = 100

xindex = (1990..2009).to_a
XMIN = xindex.min
XMAX = xindex.max
         
YMIN = 0
YMAX = 30

TICK_SIZE = 3

XAXIS = Axis.new(WIDTH, XMIN, XMAX, :x)
YAXIS = Axis.new(HEIGHT, YMIN, YMAX, :y)

data = DataSeries.new(XAXIS, YAXIS)
graph = Graph.new(XAXIS, YAXIS)

raw = File.read("aids_rawdata.csv")

x = raw.split(%r{[\r\n]+})[1..-1].map_with_index do |line, lno|

	country_data = line.split(",")
	[country_data[0], *country_data[1..20].map {|d| d.to_f}]
end.sort_by {|xx| xx[-1]}

graphs = x.map_with_index do |xx, lno|
country = xx[0]
country_data = xx[1..20]

%{
<g transform="scale(1,-1) translate(#{(2 * WIDTH * (lno) )}, -500)  ">
<g transform='translate(0,#{HEIGHT + 20}) scale(1,-1)'><text class='title' x='#{WIDTH/2}' y='0'>#{country}</text></g>
#{graph.draw_background()}
#{XAXIS.draw(xindex, :ticks_every => 2)} 
#{data.draw(xindex, country_data, "cities", :labels => :startend, :label_formatter => proc {|x, i| x.to_s + "%"}) }
</g>
}	
end.join("\n")



puts <<END
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="#{1000}" height="#{1000}" version="1.1"
     xmlns="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"     >
     <defs>
       <style type="text/css"><![CDATA[
         .forecast {
           fill: rgb(230, 230, 230);
         }
         .background {
           fill: rgb(255, 255, 255);
	   stroke: rgb(200,200,200);
           stroke-width: 0.25pt;
         }
       
         line.axis {
	   stroke: rgb(200,200,200);
           stroke-width: 0.25pt;      
         }

         .data {
           stroke-width: 1pt;
           stroke: rgb(200,0,0);
           fill: none;
         }
                  text {
          /* stroke: #8FAC8F; */
           fill: rgb(0,0,0); 
           font-family: "Helvetica Neue LT Std";
           font-size: 16px;
         }
         text.title {
           font-size: 20px;
           text-anchor: middle;
         }
         text {
           text-anchor: end;              
         }
         text.right {
           text-anchor: start;  
         }
         text.xlabel {
           text-anchor: middle;
         }
         
       ]]></style>
     </defs> 
     <g transform="scale(0.5,0.5)">  
     #{graphs}
     </g>

</svg>
END




=begin

index = 0
graphs = cities.map do |city_data, name|

  %{
<g transform="scale(1,-1) translate(#{(2 * WIDTH * (index+=1) )}, -500)  ">
<g transform='translate(0,#{HEIGHT + 20}) scale(1,-1)'><text class='title' x='#{WIDTH/2}' y='0'>#{name}</text></g>
#{graph.draw_background()}

#{XAXIS.draw(xindex, :ticks_every => 2)} 
#{data.draw(xindex, city_data, "cities", :labels => :startend, :label_formatter => proc {|x, i| ((x/100.0).round()/10.0).to_s + "m"}) }

</g>
}
end.join("\n")


graphs += total_urban.map_with_index do |data_and_name, index|
  name, total_data, urban_data = *data_and_name
  ylabel_formatter = if total_data.max > 500000
    proc {|x,i| ((x/100000.0).round()/10.0).to_s + "b"}
  else
    proc {|x,i| ((x/1000.0).round()).to_s + "m"}
  end

  yaxis = Axis.new(HEIGHT, 0, total_data.max, :y)
  data = DataSeries.new(XAXIS, yaxis)
  
  endlabel_formatter = proc do |val, index| 
                         (100.0 * val / total_data[index]).round().to_s + "%"
                       end

  %{
<g transform="scale(1,-1) translate(#{(2 * WIDTH * (index + 1) )}, -200)  ">
<g transform='translate(0,#{HEIGHT + 20}) scale(1,-1)'><text class='title' x='#{WIDTH/2}' y='0'>#{name}</text></g>
#{graph.draw_background()}

#{XAXIS.draw(xindex, :ticks_every => 2)} 
#{data.draw(xindex, total_data, "total", :labels => :startend, :label_formatter => ylabel_formatter)}
#{data.draw(xindex, urban_data, "urban", :labels => :startend, :label_formatter => endlabel_formatter)}
</g>
}
end.join("\n")

background = %{<rect style='fill:rgb(233,237,247)' x='0' y='0' width='#{2*WIDTH*(total_urban.size+1)}' height='#{600}' />}

puts <<END
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="#{1000}" height="#{1000}" version="1.1"
     xmlns="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"     >
     <defs>
       <style type="text/css"><![CDATA[
         .forecast {
           fill: rgb(230, 230, 230);
         }
         .background {
           fill: rgb(255, 255, 255);
         }
       
         line.axis {
           stroke: rgb(0,0,0);
           stroke-width: 0.25pt;      
         }

         .data {
           stroke-width: 2pt;
           fill: none;
         }
         .cities {
            stroke: rgb(255,0,0);
         }
         .urban {
           stroke: rgb(0,255,0);
         }
         .total {
           stroke: rgb(0,0,255);
         }
         text {
          /* stroke: #8FAC8F; */
           fill: rgb(0,0,0); 
           font-family: "Helvetica Neue LT Std";
           font-size: 16px;
         }
         text.title {
           font-size: 20px;
           text-anchor: middle;
         }
         text {
           text-anchor: end;              
         }
         text.right {
           text-anchor: start;  
         }
         text.xlabel {
           text-anchor: middle;
         }
         
       ]]></style>
     </defs> 
     <g transform="scale(0.5,0.5)">
     #{background}     
     #{graphs}
     </g>

</svg>
END

=end