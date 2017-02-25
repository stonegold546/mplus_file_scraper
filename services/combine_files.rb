# Central location
class CombineFiles
  def initialize(params)
    @files = params.map do |_, file|
      file
    end
    @params = params
  end

  def call
    result = combine
    string = HEADERS.join(',') + "\n"
    string += result.map do |hash|
      hash.values.join(',') + "\n"
    end.join
    string
  end

  def combine
    result = @params.map do |name, file|
      file = FileParser.new(name, file[:tempfile])
      file.call
    end
    result
  end
end
