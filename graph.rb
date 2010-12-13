class Array
    def map_with_index!
       each_with_index do |e, idx| self[idx] = yield(e, idx); end
    end

    def map_with_index(&block)
        dup.map_with_index!(&block)
    end
end

class Axis
  attr_reader :size
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
  def draw(data, options = {})
    options = {:ticks_every => 1,
               :label_formatter => proc {|x| x}}.merge(options)
    draw_ticks(data, options) + draw_labels(data, options)
  end  
  private
  def draw_ticks(data, options)
    if options[:ticks_every] == :min_max_only
    then  
      draw_min_max_ticks(data)
    else
      draw_all_ticks(data, options[:ticks_every])
    end
  end
  def draw_min_max_ticks(data)
    x,y = directions  
    min, max = scale(data.min), scale(data.max)
    %{
      <line class='axis line' #{x}1='#{min}' #{y}1='0' #{x}2='#{max}' #{y}2='0' />      
      <line class='axis tick' #{x}1='#{min}' #{y}1='0' #{x}2='#{min}' #{y}2='#{-TICK_SIZE}' />
      <line class='axis tick' #{x}1='#{max}' #{y}1='0' #{x}2='#{max}' #{y}2='#{-TICK_SIZE}' />      
    }
  end
  def draw_all_ticks(data, skip)
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
    ticks + %{ <line class="axis line" x1="0" y1="0"  x2="#{@size}" y2="0" /> }
  end
  def draw_labels(data, options)
    label_formatter = options[:label_formatter]
    label_at(scale(data.min), label_formatter.call(data.min), :min) + 
    label_at(scale(data.max), label_formatter.call(data.max), :max)
  end
  def label_at(coord, text, minmax)
    translate = case @direction
    when :x
      [coord, -8-16]
    when :y
      [-8, coord-6]
    end.join(',')

    %{ <g transform='translate(#{translate}) scale(1,-1)'>
         <text class='axis #{@direction}label #{minmax}' x='0' y='0'>#{text}</text>
       </g> }
  end

end


class DataSeries
  def initialize(xaxis, yaxis)
    @xaxis = xaxis
    @yaxis = yaxis
  end
  def draw(xseries, yseries, cssclass, options={})
    options = {:labels => :none,
               :label_formatter => proc {|x| x}}.merge(options)
    paired = []
    xseries.each_with_index do |x, k|
      paired << [x, yseries[k]]
    end
    
    draw_type = "M"
    graph_path = paired.map do |x, y|
      tmp = draw_type; draw_type = "L"
      "#{tmp} #{@xaxis.scale(x)} #{@yaxis.scale(y)}"
    end.join(" ")

    "<path class='data #{cssclass}' d='#{graph_path}' />" + draw_labels(xseries, yseries, options)
  end
  def draw_labels(xseries, yseries, options)
    return "" unless options[:labels] == :startend
    min = yseries[0]
    max = yseries[-1]
    mintext = options[:label_formatter].call(min, 0)
    maxtext = options[:label_formatter].call(max, -1)
    label_at(-4,            @yaxis.scale(min), mintext, 'left') +
    label_at(@xaxis.size+4, @yaxis.scale(max), maxtext, 'right')
  end
  def label_at(x, y, text, side)
    %{
    <g transform='translate(0, #{y-6}) scale(1,-1)'>
      <text class='series_label #{side}' x='#{x}' y='0'>#{text}</text>
    </g>
    }
  end
end

class Graph
  def initialize(xaxis, yaxis)
    @xaxis = xaxis
    @yaxis = yaxis
  end
  def draw_background()
    %{<rect class='background' x='0' y='0' width='#{@xaxis.size}' height='#{@yaxis.size}'/>}
  end
  def draw_forecast(start, xend)
    fcstx     = @xaxis.scale(start)
    fcstwidth = @xaxis.scale(xend) - fcstx
    %{<rect class='forecast' x='#{fcstx}' y='0' width='#{fcstwidth}' height='#{@yaxis.size}'/>}
  end
end
