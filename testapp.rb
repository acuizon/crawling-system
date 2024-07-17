require 'sinatra'
require 'sinatra/custom_logger'
require 'logger'

Dir[File.join(File.dirname(__FILE__), 'app', 'models', '*.rb')].each { |file| require file }

set :logger, Logger.new("log/puller.log")
set :mutex, Mutex.new

get '/' do
  'Hello World'
end

post '/crawlbase-webhook' do
  if request.user_agent == "Crawlbase Monitoring Bot 1.0"
    settings.mutex.synchronize do
      logger.info "Crawlbase Monitoring: #{request.user_agent}"
    end
  elsif request.user_agent == "Crawlbase Delivery Bot 1.0" && request.content_type == "gzip/json"
    cp = CrawlerPuller.new(request.body, settings.mutex)
    cp.process
  end

  status 200
end

CrawlerPusher.new("asins.json").process