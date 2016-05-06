require 'bundler/setup'
Bundler.require

require 'yaml'
Dotenv.load

class ShowcaseTracker < Sinatra::Application
  ROOT = Pathname.new(__FILE__).parent
  ROOT_ERB = ERB.new(ROOT.join('page.html.erb').read)
  PROGRESS = YAML.load(ROOT.join('progress.yml').read)

  def initialize(conn = nil)
    @conn = conn || begin
      Sequel.connect(ENV['DATABASE_URL'],
                     max_connections: ENV['MAX_THREADS'])
    end

    super()
  end

  not_found do
    status 404
    body 'Oops! Could not find this page.'
  end

  get '/' do
    messages = @conn[<<-SQL]
      SELECT * FROM messages ORDER BY created_at DESC
    SQL
    messages.map(&:to_s)
    progress = progress = PROGRESS[ENV['PROGRESS_STAGE'].to_i]
    ROOT_ERB.result(binding)
  end

  post '/' do
    @conn.transaction do
      @conn[:messages].insert(
        :content => params[:message].to_s,
        :created_at => DateTime.now,
      )
    end
    redirect back
  end

  run!
end
