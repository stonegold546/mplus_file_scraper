LL = /H0 Value\s+(\-?\d+\.?\d*)/
DF = /Number of Free Parameters\s+(\d+)/
AIC = /Akaike \(AIC\)\s+(\-?\d+\.?\d*)/
BIC = /Bayesian \(BIC\)\s+(\-?\d+\.?\d*)/
ENTROPY = /Entropy\s+(\-?\d+\.?\d*)/
TECH11 = /TECHNICAL 11 OUTPUT.+?RUBIN ADJUSTED LRT.+?P-Value\s+(\-?\d+\.?\d*)/m
TECH14 = /TECHNICAL 14 OUTPUT.+?Approximate P-Value\s+(\-?\d+\.?\d*)/m
ITEMS = [CLASSES, LL, DF, AIC, BIC, ENTROPY, TECH11, TECH14].freeze

# File parsing class
class FileParser
  def initialize(name, file)
    @name = name
    @contents = File.read file
  end

  def call
    extraction_csv = ExtractMeans.new(@name, @contents).call
    values = scanner << @name
    [HEADERS.zip(values).to_h, extraction_csv]
  end

  def scanner
    ITEMS.map do |match|
      dat = @contents.scan(match)[0]
      dat.nil? ? '' : dat[0]
    end
  end
end
