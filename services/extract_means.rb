# TODO: Fix TECH11 and TECH14

NUM_DV = /Number of dependent variables\s+(\d+)/
USE_VARS = /usevariables =\s+?(.+?);/m
RESULTS = /Model Results/

# Get means from Model Results
class ExtractMeans
  def initialize(contents)
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
    ap results
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
        result.nil? ? '' : result[0].to_f
      end
    end
  end
end
