DOUBLE_LINE = "\n\n".freeze

# Central location
class CombineFiles
  def initialize(params)
    @files = params.map do |_, file|
      file
    end
    @params = params
  end

  def call
    summary, classes = combine
    string = HEADERS.join(',') + "\n"
    string += summary.map do |hash|
      hash.values.join(',') + "\n"
    end.join
    string + DOUBLE_LINE + classes.compact.join(DOUBLE_LINE)
  end

  def combine
    result = @params.map do |name, file|
      file = FileParser.new(name, file[:tempfile])
      file.call
    end
    result.transpose
  end
end
