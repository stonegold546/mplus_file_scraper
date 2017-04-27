require 'sinatra'
require 'slim'
require 'slim/include'
require 'kramdown'
require 'rack-ssl-enforcer'
require 'config_env'
require 'ap'
require 'classy_hash'

SCHEMA = {
  filename: /\w.out/,
  type: %r{application/octet-stream},
  name: String,
  tempfile: Tempfile,
  head: String
}.freeze

HEADERS = %w(
  classes LL Free\ Parameters AIC BIC SABIC Entropy tech11_LMR_p
  tech14_approx_p filename
).freeze
CLASSES = /c\((\d*)/
TOO_FEW = 'Number of classes in syntax file must not be less than 1 and'\
  ' must not be greater than or equal to the maximum number of classes.'.freeze

configure :development, :test do
  ConfigEnv.path_to_config('config/config_env.rb')
end

# Base app
class MplusFileScraper < Sinatra::Base
  enable :logging

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  configure :production do
    use Rack::SslEnforcer
    set :session_secret, ENV['MSG_KEY']
  end

  root = lambda do
    slim :index
  end

  process_files = lambda do
    ap params
    params.each do |_, file|
      begin File.readlines(file[:tempfile]).grep(/monitor/)
      rescue
        halt 400, "#{file[:name]} is probably not an Mplus output file."
      end
      begin ClassyHash.validate(file, SCHEMA)
      rescue => e
        halt 400, "#{file[:name]}: #{e.message}"
      end
    end
    combined_files = CombineFiles.new(params)
    combined_files.call
  end

  lca_inps = lambda do
    lca_inp_vals = LcaInpVal.new(params)
    halt 400, lca_inp_vals.errors.messages.to_s unless lca_inp_vals.valid?
    lca_inp_bat = LCAInpBatMaker.new(lca_inp_vals)
    results = lca_inp_bat.call
    halt 400, TOO_FEW if results == '400_TOO_FEW'
    results
  end

  get '/', &root

  post '/files/?', &process_files

  post '/lca_inps/?', &lca_inps

  get '/keybase.txt' do
    File.read(File.join('public', 'keybase.txt'))
  end
end
