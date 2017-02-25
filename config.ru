# \ -s puma

Dir.glob('./{controllers,services}/*.rb').each do |file|
  require file
end
run MplusFileScraper
