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

      # Read books' metadata
      metadata_content.xpath("/DBLMetadata/publications/publication/structure/content").each.with_index(1) do |book_info, book_number|
        # Extract bible data
        book_code = book_info["role"]
        book_name = book_info["name"]
        book_title = metadata_content.at_xpath("/DBLMetadata/names/name[@id=\"#{book_name}\"]/long").content

        # Save book data into database
        book = Book.find_or_create_by!(bible: bible, title: book_title, number: book_number, code: book_code)
        Rails.logger.info "Loaded Bible Book ##{book.number}: [#{book.code}] #{book.title}"
      end
    end
  end
end
