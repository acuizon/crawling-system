require 'logger'
require 'json_csv'

class CrawlerExporter

  attr_accessor :filename, :logger, :mutex

  def initialize(filename, mutex = Mutex.new)
    @filename = filename
    @logger = Logger.new("log/exporter.log")
    @mutex = mutex
  end

  def process
    Thread.new do
      begin
        if File.exists?("output/#{filename}.json")
          json_data = JSON.parse(File.read("output/#{filename}.json"))
          JsonCsv.create_csv_for_json_records("output/#{filename}.csv") do |csv_builder|
            csv_builder.add(json_data)
          end

          info_log("#{filename}: Exported to #{filename}.csv")
        end
      rescue => e
        error_log("#{filename}: #{e.message}")
      end
    end.join
  end

  protected

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