require 'sinatra'
require 'slim'
require 'slim/include'
require 'kramdown'
require 'rack-ssl-enforcer'
require 'config_env'
require 'ap'
require 'classy_hash'

SCHEMA = {
  filename: String,
  type: %r{application/octet-stream},
  name: String,
  tempfile: Tempfile,
  head: String
}.freeze

HEADERS = %w(classes ll df aic bic entropy tech11 tech14 filename).freeze

configure :development, :test do
  ConfigEnv.path_to_config("#{__dir__}/config/config_env.rb")
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
    params.each do |_, file|
      begin ClassyHash.validate(file, SCHEMA)
      rescue => e
        halt 400, e.message
      end
    end
    combined_files = CombineFiles.new(params)
    combined_files.call
  end

  get '/', &root

  post '/files/?', &process_files
end
