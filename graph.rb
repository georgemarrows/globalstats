
WIDTH = 100
HEIGHT = 100

xindex = [1950,1955,1960,1965,1970,1975,1980,1985,1990,1995,2000,2005,2010,2015,2020]
XMIN = xindex.min
XMAX = xindex.max


cities= [[[11275,13713,16679,20284,23298,26615,28549,30304,32530,33587,34450,35327,35676,36094,36371,36399],  "Tokyo"],
         [[2857,3432,4060,4854,5811,7082,8658,10341,12308,14111,16086,18202,18978,20072,21946,24051],         "Mumbai"],
         [[2334,3044,3970,5494,7620,9614,12089,13395,14776,15948,17099,18333,18845,19582,20544,21124],        "Sao Paulo"],
         [[2883,3801,5012,6653,8769,10690,13010,14109,15312,16811,18022,18735,19028,19485,20189,20695],       "Mexico City"],        
         [[1369,1782,2283,2845,3531,4426,5558,6769,8206,10092,12441,15053,15926,17015,18669,20484],           "Delhi"],
         [[12338,13219,14164,15177,16191,15880,15601,15827,16086,16943,17846,18732,19040,19441,19974,20370],  "New York"],
         [[336,409,508,821,1374,2221,3266,4660,6621,8332,10285,12576,13485,14796,17015,19422],                "Dhaka"],
         [[4513,5055,5652,6261,6926,7888,9030,9946,10890,11924,13058,14282,14787,15577,17039,18707],          "Kolkata"],
         
         ]
YMIN = 0
YMAX = 38

TICK_SIZE = 3

class Array
    def map_with_index!
       each_with_index do |e, idx| self[idx] = yield(e, idx); end
    end

    def map_with_index(&block)
        dup.map_with_index!(&block)
    end
end

class Axis
  def initialize(size, min, max, direction)
    @size = size
    @min = min
    @max = max
    @direction = direction
  end
  def scale(value)
    @size * (value - @min) / (@max - @min)
  end
  def directions
    case @direction
    when :x
      ['x','y']
    when :y
      ['y','x']
    else
      raise "Unknown direction #{@direction}"
    end
  end
  def ticks(data, skip=1)
    x,y = directions
    data = data.map_with_index {|d, ndx| if ndx % skip == 0 then d else false end}
    ticks = data.map do |val|
      if val
      then
        v = scale(val)
        %{<line class='axis ticks' #{x}1='#{v}' #{y}1='0' #{x}2='#{v}' #{y}2='#{-TICK_SIZE}' />}
      else
        ""
      end
      
    end.join("")
    ticks += %{ <line class="axis line" x1="0" y1="0"  x2="#{@size}" y2="0" /> }
  end  
end

class TufteAxis < Axis
  def ticks(data)
    x,y = directions
    min, max = scale(data.min), scale(data.max)
    textx = -8
    ticks = %{
      <line class='axis line' #{x}1='#{min}' #{y}1='-1' #{x}2='#{max}' #{y}2='-1' />      
      <line class='axis tick' #{x}1='#{min}' #{y}1='-1' #{x}2='#{min}' #{y}2='#{-1-TICK_SIZE}' />
      <line class='axis tick' #{x}1='#{max}' #{y}1='-1' #{x}2='#{max}' #{y}2='#{-1-TICK_SIZE}' />      
      <g transform='translate(0,#{min-3}) scale(1,-1)'><text class='axis label' x='#{textx}' y='0'>#{data.min}</text></g>
      <g transform='translate(0,#{max-3}) scale(1,-1)'><text class='axis label' x='#{textx}' y='0'>#{data.max}</text></g>      
    }
    
   
  end
end

XAXIS = Axis.new(WIDTH, XMIN, XMAX, :x)
YAXIS = TufteAxis.new(HEIGHT, YMIN, YMAX, :y)

class DataSeries
  def initialize(xaxis, yaxis)
    @xaxis = xaxis
    @yaxis = yaxis
  end
  def draw(xseries, yseries)
    paired = []
    xseries.each_with_index do |x, k|
      paired << [x, yseries[k]]
    end
    
    draw_type = "M"
    graph_path = paired.map do |x, y|
      tmp = draw_type; draw_type = "L"
      "#{tmp} #{XAXIS.scale(x)} #{YAXIS.scale(y)}"
    end.join(" ")

    "<path class='data' d='#{graph_path}' />"
  end
end

data = DataSeries.new(XAXIS, YAXIS)

#[0,10,20,30,40])}

index = 0
graphs = cities.map do |c, name|
  city_data = c.map {|x| (x/100.0).round()/10.0}
  fcstx = XAXIS.scale(2010)
  fcstwidth = XAXIS.scale(2020) - fcstx
  %{
<g transform="scale(1,-1) translate(#{(1.6 * HEIGHT * (index+=1) )}, -200)  ">
<g transform='translate(0,#{HEIGHT + 10}) scale(1,-1)'><text class='title' x='0' y='0'>#{name}</text></g>
<rect class='forecast' x='#{fcstx}' y='0' width='#{fcstwidth}' height='#{HEIGHT}'/>
#{XAXIS.ticks(xindex, 2)} 
#{YAXIS.ticks(city_data)}
#{data.draw(xindex, city_data)}

</g>
}
end.join("\n")

#    <g transform="scale(1,-1) translate(50,#{-HEIGHT-50})">
#    #{XAXIS.ticks(xindex)} 
#    #{YAXIS.ticks([0,10,20,30,40])}
#    #{data.draw(xindex, tokyo)}
#    </g>

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
         .axis {
           stroke: #8FAC8F;
         }
         line.axis {
           stroke-width: 2;      
         }
         text.axis {
           text-anchor: end;              
         }
         .data {
           stroke: rgb(255,0,0);
           stroke-width: 2;
           fill: none;
         }
         text {
           stroke: #8FAC8F;
           fill: #8FAC8F;
           font-family: "GillSans";
           font-size: 16px;
         }
         text.title {
           font-size: 20px;
         }         
         
       ]]></style>
     </defs> 
     <g transform="scale(0.6,0.6)">
     #{graphs}
     </g>

</svg>
END