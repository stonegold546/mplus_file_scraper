# Make bat string
class LCAInpBatMaker
  def initialize(lca_inp_vals)
    @max_num_classes = lca_inp_vals.max_num_classes
    @mplus_type = lca_inp_vals.mplus_type
    @lca_inp_area = lca_inp_vals.lca_inp_area
    @dat_file = lca_inp_vals.dat_file
    @min_classes = lca_inp_vals.min_classes
    @sys_os = lca_inp_vals.sys_os
    @auto_col = lca_inp_vals.auto_collate
  end

  def call
    return '400_TOO_FEW' if @min_classes >= @max_num_classes || @min_classes < 1
    syntaxes = inputs
    newline = @sys_os == 'windows' ? "\r\n" : "\n"
    bat_dat, dir_name = create_bat_file(newline)
    bat_dat = add_syntax(bat_dat, syntaxes, newline)
    bat_dat = clean_dir_structure(bat_dat, dir_name, newline)
    return bat_dat if @auto_col == 'no'
    collate(bat_dat, dir_name, newline)
  end

  def inputs
    (@min_classes..@max_num_classes).to_a.map do |num_classes|
      [
        "inp_file_#{num_classes}.inp",
        @lca_inp_area.gsub(
          /clas.*=.*c.*\(.*(\d+).*\)/i,
          "CLASSES = c(#{num_classes})"
        )
      ]
    end.to_h
  end

  def create_bat_file(newline)
    work_dir, copy =
      if @sys_os == 'windows' then ['', 'xcopy']
      else ['./', 'cp']
      end
    date_time = DateTime.now.to_s.gsub(/[^0-9a-z]/i, '')
    output_folder = "#{work_dir}output-#{date_time}"
    bat_dat = "mkdir #{output_folder}#{newline}"
    bat_dat << "#{copy} #{@dat_file} #{output_folder}#{newline}"
    bat_dat << "cd #{work_dir}output-#{date_time}#{newline}"
    [bat_dat, date_time.to_s]
  end

  def add_syntax(bat_dat, syntaxes, newline)
    syntaxes.map do |key, value|
      bat_dat << "(#{newline}"
      value.split("\n").map do |line|
        line = escape(line)
        bat_dat << "echo #{line}#{newline}" unless line.strip.empty?
      end
      bat_dat << ")> #{key}#{newline}#{@mplus_type} #{key}#{newline}"
    end
    bat_dat
  end

  def escape(line)
    if @sys_os == 'unix' then Shellwords.escape(line)
    else
      line.gsub('^', '^^').gsub('%', '%%').gsub('\\', '^\\').gsub('!', '^^!')
          .gsub('&', '^&').gsub(')', '^)').gsub(/\s+/, ' ')
    end
  end

  def clean_dir_structure(bat_dat, dir_name, newline)
    dir_slash, move, del =
      if @sys_os == 'windows' then ['\\', 'move', 'del']
      else ['/', 'mv', 'rm']
      end
    bat_dat << "cd ..#{newline}mkdir input-#{dir_name}#{newline}"
    bat_dat << "#{move} output-#{dir_name}#{dir_slash}inp_file_*.inp "\
      "input-#{dir_name}#{dir_slash}#{newline}"
    bat_dat << "#{del} output-#{dir_name}#{dir_slash}#{@dat_file}"
    bat_dat
  end

  def collate(bat_dat, dir_name, newline)
    windows_stuff = [bat_dat, @min_classes, @max_num_classes, dir_name]
    return WindowsMultipart.new(windows_stuff).call if @sys_os == 'windows'
    bat_dat << "#{newline}cd output-#{dir_name}#{newline}curl"
    (@min_classes..@max_num_classes).to_a.map do |num_classes|
      file_name = "inp_file_#{num_classes}.out"
      bat_dat << " -F '#{file_name}=@#{file_name}'"
    end
    bat_dat << " #{ENV['MPLUS_SITE']}/files > ../result-#{dir_name}.csv"
    bat_dat
  end
end
