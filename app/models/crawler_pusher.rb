require 'net/http'
require 'parallel'

class CrawlerPusher

  attr_accessor :filename

  def initialize(filename)
    @filename = filename
    @token = 'sVtEYTCZtwyETYMIiiihxA'
  end

  def process
    asins = fetch_asins(filename)

    if asins.size > 1
      push_parallel(asins)
    else
      push_one(asins.first)
    end
  end

  def fetch_asins
    if File.exists?("lib/#{filename}")
      file_data = File.read("lib/#{filename}")
      parsed_data = JSON.parse(file_data)

      parsed_data['amazon_asins']
    else
      []
    end
  end

  protected

  def push_parallel(asins)
    Parallel.map(asins, in_threads: 5) do |asin|
      uri = URI('https://api.crawlbase.com')
      uri.query = URI.encode_www_form({
        token: @token,
        url: "https://www.amazon.com/dp/#{asin}",
        autoparse: 'true'
      })
    end
  end

  def push_one(asin)

  end

end