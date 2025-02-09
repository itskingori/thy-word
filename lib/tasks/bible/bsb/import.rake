namespace :bible do
  namespace :bsb do
    task import: :environment do
      Rails.logger = Logger.new(STDOUT)
      Rails.logger.level = Logger::INFO

      # Read bible metadata
      bible_folder = File.join(Rails.root, "db", "data", "bibles", "BSB")
      metadata_file_path = File.join(bible_folder, "metadata.xml")
      metadata_file = File.read(metadata_file_path)
      metadata_content = Nokogiri::XML(metadata_file)

      # Extract bible data
      bible_abbreviation = metadata_content.at_xpath("/DBLMetadata/identification/abbreviation").content
      bible_name = metadata_content.at_xpath("/DBLMetadata/identification/name").content
      bible_statement = metadata_content.at_xpath("/DBLMetadata/copyright/fullStatement/statementContent/p").content
      bible_rights_holder_name = metadata_content.at_xpath("/DBLMetadata/agencies/rightsHolder/name").content
      bible_rights_holder_url = metadata_content.at_xpath("/DBLMetadata/agencies/rightsHolder/url").content

      # Save bible data into database
      bible = Bible.find_or_create_by!(name: bible_name, code: bible_abbreviation, statement: bible_statement, rights_holder_name: bible_rights_holder_name, rights_holder_url: bible_rights_holder_url)
      Rails.logger.info "Loaded Bible: [#{bible.code}] #{bible.name}"
    end
  end
end
