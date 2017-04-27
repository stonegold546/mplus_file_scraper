# TODO: Create PowerShell script to execute

require 'securerandom'

# Auto collate bat string on Windows
class WindowsMultipart
  def initialize(windows_stuff)
    @bat_dat = windows_stuff[0]
    @min_classes = windows_stuff[1]
    @max_classes = windows_stuff[2]
    @dir_name = windows_stuff[3]
    @boundary = boundary
    @crlf = '`r`n'
  end

  def call
    @bat_dat << "\r\ncd output-#{@dir_name}\r\n"
    create_powershell_script
    @bat_dat << 'PowerShell.exe -executionpolicy remotesigned -File collate.ps1'
    @bat_dat
  end

  def create_powershell_script
    @bat_dat << "(\r\n"
    file_content_into_bat_dat
    define_other_vars
    @bat_dat << 'echo Invoke-RestMethod -Uri $URL -Method Post '\
      '-ContentType "multipart/form-data; boundary=`"$boundary`"" '\
      "-Body $text -Outfile ..\\result-#{@dir_name}.csv\r\n"
    @bat_dat << ")> collate.ps1\r\n"
  end

  def boundary
    '-' * 35 + SecureRandom.hex
  end

  def define_other_vars
    @bat_dat << "echo $URL = \"#{ENV['MPLUS_SITE']}/files\"\r\n"
    @bat_dat << "echo $boundary = \"#{@boundary}\"\r\n"
    @bat_dat << "echo $text = \"#{text}\"\r\n"
  end

  def text
    text = (@min_classes..@max_classes).map do |n_classes|
      file_name = "inp_file_#{n_classes}.out"
      "--$boundary#{@crlf}Content-Disposition: form-data; "\
      "name=`\"#{file_name}`\"; filename=`\"#{file_name}`\"#{@crlf}"\
      "Content-Type: text/plain#{@crlf}#{@crlf}$file_#{n_classes}_content"
    end.join(@crlf.to_s)
    text + "#{@crlf}--$boundary--#{@crlf}"
  end

  def file_content_into_bat_dat
    (@min_classes..@max_classes).map do |n_classes|
      @bat_dat << "echo $file_#{n_classes}_content = "\
      "Get-Content inp_file_#{n_classes}.out\r\n"
    end
  end
end
