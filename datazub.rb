class DataZub
  def initialize(data_array)
    @data = data_array
  end
  def to_array
    @data
  end
  def to_hash
  	  result = {}
  	  @data.each do |d|
  	  	  result[d[0]] = d[1]
  	  end
  	  result
  end
  # reshaper args from shape => to shape
  # eg [*] -> [0, [3..-1]]
  # or only allow flat arrays?
  def cselect(*indexes)
    if indexes.size == 1
      return cselect_explode(indexes[0])
    end 
    new_data = 
      @data.map do |row|
        new_row = []
        indexes.each do |index|
          if index.kind_of?(Range)
            new_row.push(*row[index])
          else
            new_row.push(row[index])
          end
        end
        new_row
      end
    DataZub.new(new_data)
  end
  def cselect_explode(index)
    new_data = 
      @data.map do |row|
        row[index]
      end
    DataZub.new(new_data)
  end
  def transform(index, p)
    new_data = @data.map do |row|
      new_row = row.clone
      new_row[index] = row[index].send(p)
      new_row
    end
    DataZub.new(new_data)
  end
  def sum
    @data.inject {|memo, d| memo+d}
  end
  def average
    sum() / @data.size
  end
  def DataZub.from_csv(fname, num_headers)
    raw = File.read(fname)
    data = raw.split(%r{[\r\n]+})[num_headers..-1].map_with_index do |line, lno|
      line.split(",")
    end
    DataZub.new(data)
  end
end
