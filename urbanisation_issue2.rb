require 'graph'

WIDTH = 100
HEIGHT = 100

xindex = [1950,1955,1960,1965,1970,1975,1980,1985,1990,1995,2000,2005,2010,2015,2020]
XMIN = xindex.min
XMAX = xindex.max

# Source: http://esa.un.org/unup - city population, 1000s
cities= [[[11275,13713,16679,20284,23298,26615,28549,30304,32530,33587,34450,35327,35676,36094,36371,36399],  "Tokyo"],
         [[2857,3432,4060,4854,5811,7082,8658,10341,12308,14111,16086,18202,18978,20072,21946,24051],         "Mumbai"],
         [[2334,3044,3970,5494,7620,9614,12089,13395,14776,15948,17099,18333,18845,19582,20544,21124],        "Sao Paulo"],
         [[2883,3801,5012,6653,8769,10690,13010,14109,15312,16811,18022,18735,19028,19485,20189,20695],       "Mexico City"],        
         [[1369,1782,2283,2845,3531,4426,5558,6769,8206,10092,12441,15053,15926,17015,18669,20484],           "Delhi"],
         [[12338,13219,14164,15177,16191,15880,15601,15827,16086,16943,17846,18732,19040,19441,19974,20370],  "New York"],
         #[[336,409,508,821,1374,2221,3266,4660,6621,8332,10285,12576,13485,14796,17015,19422],                "Dhaka"],
         #[[4513,5055,5652,6261,6926,7888,9030,9946,10890,11924,13058,14282,14787,15577,17039,18707],          "Kolkata"],
         
         ]
         
# Source: http://esa.un.org/unup - urban population as %age         
urban_growth = [
         [[63.9,67.0,69.9,72.0,73.8,73.8,73.9,74.7,75.4,77.3,79.1,80.7,82.1,83.4,84.6],"Northern America"],
         [[41.4,45.1,48.9,53.0,57.0,61.1,64.9,67.9,70.6,73.0,75.3,77.5,79.4,80.9,82.3],"Latin America and the Caribbean"],
         [[51.2,54.0,56.9,60.0,62.8,65.7,68.0,69.4,70.5,71.0,71.4,71.9,72.6,73.5,74.8],"Europe"],
         [[62.0,64.3,66.6,68.8,70.8,71.5,71.3,70.7,70.6,70.5,70.4,70.5,70.6,70.9,71.4],"Oceania"],
         [[29.1,30.9,32.9,34.7,36.0,37.3,39.1,40.9,43.0,44.7,46.6,48.6,50.6,52.7,54.9],"World"],
         [[16.8,18.2,19.8,21.5,22.7,24.0,26.3,29.0,31.9,34.4,37.1,39.7,42.5,45.3,48.1],"Asia"],
         [[14.5,16.4,18.7,21.3,23.6,25.7,27.9,29.9,32.0,34.1,35.9,37.9,39.9,42.2,44.6],"Africa"],
       ]
         
total_urban = [  # format: country, total pop in 1000s, urban pop in 1000s
        ["World",
          [2535093,2770753,3031931,3342771,3698676,4076080,4451470,4855264,5294879,5719045,6124123,6514751,6906558,7295135,7667090],
          [736796,854955,996298,1160982,1331783,1518520,1740551,1988195,2274554,2557386,2853909,3164635,3494607,3844664,4209669]],
        ["USA",  
          [157813,171074,186158,199386,210111,220165,230917,243063,256098,270245,284857,299846,314692,329010,342547],
          [101242,114899,130302,143316,154647,162157,170274,181069,192842,208779,225319,242236,258998,275248,290729]],      
        #["Mexico",
        #  [27741,32253,37877,44406,52028,60713,69325,76826,84002,91823,99735,104266,110293,115756,120559],
        #  [11833,15056,19224,24393,30707,38103,45990,52971,59994,67368,74524,79564,85839,91777,97265]],
        ["Japan",
          [83625,89815,94096,98881,104331,111524,116807,120837,123537,125472,127034,127897,127758,126607,124489],
          [29145,34928,40542,46852,55508,63373,69577,73173,77944,81098,82847,84363,85385,86082,86420]],
        ["China",
          [554760,609005,657492,729191,830675,927808,998877,1066906,1149069,1213732,1269962,1312979,1351512,1388600,1421260],
          [72119,86363,105246,128093,144537,161439,196220,245322,314845,380553,454362,530659,607230,683474,756340]],
        ["India",
          [371857,405529,445981,493868,549312,613767,688575,771121,860195,954282,1046235,1134403,1220182,1302535,1379198],
          [63373,71301,79938,92773,108546,130927,159046,187754,219758,253774,289438,325563,366858,415612,472561]],
        #["Bangladesh",
        #  [43852,48415,54253,61479,69817,78993,88855,100532,113049,126297,139434,153281,166638,180114,193333],
        #  [1878,2269,2786,3818,5301,7770,13196,17589,22396,27398,32893,39351,46770,55474,65523]],          
        ["Ethiopia",  
          [18434,20474,22942,26087,29831,34188,37138,43437,51148,60293,69388,78986,89566,100967,112896],
          [848,1115,1476,1979,2562,3234,3866,4975,6455,8381,10339,12687,15722,19564,24369]],

          
       ];

         
YMIN = 0
YMAX = 38000

TICK_SIZE = 3

XAXIS = Axis.new(WIDTH, XMIN, XMAX, :x)
YAXIS = Axis.new(HEIGHT, YMIN, YMAX, :y)

data = DataSeries.new(XAXIS, YAXIS)
graph = Graph.new(XAXIS, YAXIS)

index = 0
graphs = cities.map do |city_data, name|

  %{
<g transform="scale(1,-1) translate(#{(2 * WIDTH * (index+=1) )}, -500)  ">
<g transform='translate(0,#{HEIGHT + 20}) scale(1,-1)'><text class='title' x='#{WIDTH/2}' y='0'>#{name}</text></g>
#{graph.draw_background()}
#{graph.draw_forecast(2010, 2020)}
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
#{graph.draw_forecast(2010, 2020)}
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