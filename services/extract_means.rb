# TODO: Fix TECH11 and TECH14

PROB = 'RESULTS IN PROBABILITY SCALE'.freeze

USE_VARS_C = Regexp.new(
  'Observed dependent variables\s+Continuous\s+(.+?)\s+'\
  'Categorical latent variables',
  Regexp::MULTILINE
)
USE_VARS_B = Regexp.new(
  'Observed dependent variables\s+Binary and ordered categorical \(ordinal\)'\
  '\s+(.+?)\s+Categorical latent variables', Regexp::MULTILINE
)

# Get means or probabilities from Model Results
class ExtractMeansProbs
  def initialize(file_name, contents)
    @file_name = file_name
    @contents = contents
    @cat = nil
  end

  def call
    num_classes = @contents.scan(CLASSES)[0]
    return nil if num_classes.nil?
    num_classes = num_classes[0].to_f
    dvs = obtain_dvs
    return nil if dvs.nil?
    search_regexes = searches(num_classes, dvs)
    results = results(search_regexes)
    make_csv(results, dvs)
  end

  def obtain_dvs
    dvs = @contents.scan(USE_VARS_C)[0]
    if dvs.nil?
      @cat = TRUE
      dvs = @contents.scan(USE_VARS_B)[0]
    end
    return nil if dvs.nil?
    dvs = dvs[0]
    dvs.split.map(&:upcase)
  end

  def searches(num_classes, dvs)
    (1..num_classes).to_a.map do |x|
      dvs.map do |dv|
        if @cat
          Regexp.new("#{PROB}.+?Latent Class #{x}.+?#{dv}.+?Category 2\\s+"\
                     '(-?\d+.?\d+)', Regexp::MULTILINE)
        else
          Regexp.new("Latent Class #{x}.+?#{dv}.+?" + '(-?\d+.?\d+)',
                     Regexp::MULTILINE)
        end; end; end
  end

  def results(search_regexes)
    search_regexes.map do |variables|
      variables.map do |variable|
        result = @contents.scan(variable)[0]
        result.nil? ? '' : result[0]
      end
    end
  end

  def make_csv(results, dvs)
    results = results.insert(0, dvs)
    results = results.each_with_index.map do |variables, i|
      start = i.zero? ? 'Classes,' : "Class #{i},"
      start + variables.join(',')
    end.join("\n")
    'source_file: ' + @file_name + "\n" + results
  end
end
