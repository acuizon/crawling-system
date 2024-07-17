require 'sinatra'

Dir[File.join(File.dirname(__FILE__), 'app', 'models', '*.rb')].each { |file| require file }

get '/' do
  Hello World
end

post '/crawlbase-webhook' do
  
end