require 'logger'
require 'zlib'

class CrawlerPuller

  attr_accessor :body, :logger

  def initialize(body)
    @body = body
    @logger = Logger.new("log/puller.log")
  end

  def process
    Thread.new do 
      begin
        result = Zlib::GzipReader.new(body).read

        parse_and_write(result)
      rescue => e
        logger.error("#{e.message}")
      end
    end
  end

  protected

  def asin_code(url)
    url.split("/").last
  end

  def parse_and_write(result)
    parsed = JSON.parse(result)
    filename = asin_code(parsed['url'])
    if filename
      File.open("output/#{filename}.json", "w") do |f|
        f.puts(parsed)
      end

      logger.info("#{asin_code(parsed['url'])}: Parsed Webhook body and stored output in JSON file: #{filename}.json")
    end
  end

end