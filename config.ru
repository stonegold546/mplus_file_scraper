# \ -s puma

Dir.glob('./{controllers,services,values}/*.rb').each do |file|
  require file
end
run MplusFileScraper
