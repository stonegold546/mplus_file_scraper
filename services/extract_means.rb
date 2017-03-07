# TODO: Fix TECH11 and TECH14

NUM_DV = /Number of dependent variables\s+(\d+)/
USE_VARS = /Observed dependent variables\s+Continuous\s+(.+?)\s+Categorical/m
RESULTS = /Model Results/

# Get means from Model Results
class ExtractMeans
  def initialize(file_name, contents)
    @file_name = file_name
    @contents = contents
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
    dvs = @contents.scan(USE_VARS)[0]
    return nil if dvs.nil?
    dvs = dvs[0]
    dvs.split.map(&:upcase)
  end

  def searches(num_classes, dvs)
    (1..num_classes).to_a.map do |x|
      dvs.map do |dv|
        Regexp.new("Latent Class #{x}.+?#{dv}.+?" + '(-?\d+.?\d+)',
                   Regexp::MULTILINE)
      end
    end
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
