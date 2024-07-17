require 'logger'
require 'zlib'

class CrawlerPuller

  attr_accessor :body, :logger, :mutex

  def initialize(body, mutex = Mutex.new)
    @body = body
    @logger = Logger.new("log/puller.log")
    @mutex = mutex
  end

  def process
    filename = nil
    Thread.new do 
      begin
        result = Zlib::GzipReader.new(body).read
        parsed = JSON.parse(result)

        if parsed['pc_status'] == 200
          filename = asin_code(parsed['url'])
          create_json_file(filename, parsed['body'])
        end
      rescue => e
        error_log("#{e.message}")
      end
    end.join

    if filename
      CrawlerExporter.new(filename, mutex).process
    end
  end

  protected

  def asin_code(url)
    url.split("/").last
  end

  def create_json_file(filename, body)
    if filename
      File.open("output/#{filename}.json", "w") do |f|
        f.puts(body)
      end

      info_log("#{filename}: Parsed Webhook body and stored output in JSON file: #{filename}.json")
    end
  end

  def info_log(msg)
    mutex.synchronize do
      logger.info(msg)
    end
  end

  def error_log(msg)
    mutex.synchronize do
      logger.error(msg)
    end
  end

end