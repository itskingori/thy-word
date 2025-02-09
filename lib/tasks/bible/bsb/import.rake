namespace :bible do
  namespace :bsb do
    task import: :environment do
      Rails.logger = Logger.new(STDOUT)
      Rails.logger.level = Logger::INFO
    end
  end
end
