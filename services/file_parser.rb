# TODO: Fix TECH11 and TECH14

CLASSES = /c\((\d*)/
LL = /H0 Value\s+(\-?\d+\.?\d*)/
DF = /Number of Free Parameters\s+(\d+)/
AIC = /Akaike \(AIC\)\s+(\-?\d+\.?\d*)/
BIC = /Bayesian \(BIC\)\s+(\-?\d+\.?\d*)/
ENTROPY = /Entropy\s+(\-?\d+\.?\d*)/
TECH11 = /P-Value\s+(\-?\d+\.?\d*)/ # SPECIAL!!!!
TECH14 = /Approximate P-Value\s+(\-?\d+\.?\d*)/
ITEMS = [CLASSES, LL, DF, AIC, BIC, ENTROPY, TECH11, TECH14].freeze

# File parsing class
class FileParser
  def initialize(name, file)
    @name = name
    @contents = File.read file
  end

  def call
    values = scanner << @name
    HEADERS.zip(values).to_h
  end

  def scanner
    ITEMS.map do |match|
      @contents.scan(match)[0][0]
    end
  end
end
