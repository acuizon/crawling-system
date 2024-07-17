require 'net/http'
require 'parallel'
require 'logger'

class CrawlerPusher

  attr_accessor :filename, :logger

  def initialize(filename)
    @filename = filename
    @token = 'sVtEYTCZtwyETYMIiiihxA'
    @logger = Logger.new("log/pusher.log")
  end

  def process
    urls = fetch_asin_urls

    if urls.size > 1
      push_parallel(urls)
    else
      push_one(urls.first)
    end
  end

  def fetch_asin_urls
    if File.exists?("lib/#{filename}")
      file_data = File.read("lib/#{filename}")
      parsed_data = JSON.parse(file_data)

      parsed_data['amazon_asin_urls']
    else
      []
    end
  end

  protected

  def push_parallel(urls)
    Parallel.map(urls, in_threads: 5, finish: -> (item, i, result) { result&.code == "200" ? logger.info("#{asin_code(item)}: OK") : logger.error("#{asin_code(item)}: FAILED - #{result&.body}") }) do |url|
      push_one(url)
    end
  end

  def push_one(url)
    logger.info("#{asin_code(url)}: Started crawling..")
    begin
      response = Net::HTTP.get_response(prepare_uri(url))
    rescue => e
      logger.error("#{asin_code(url)}: FAILED - #{e.message}")
    end

  end

  def prepare_uri(url)
    uri = URI('https://api.crawlbase.com')
    uri.query = URI.encode_www_form({
      token: @token,
      url: url,
      autoparse: 'true',
      store: 'true'
      # callback: 'true',
      # crawler: 'testcrawler'
    })

    uri
  end

  def asin_code(url)
    url.split("/").last
  end
end