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

      # Read books' metadata and contents
      metadata_content.xpath("/DBLMetadata/publications/publication/structure/content").each.with_index(1) do |book_info, book_number|
        # Extract bible data
        book_code = book_info["role"]
        book_name = book_info["name"]
        book_title = metadata_content.at_xpath("/DBLMetadata/names/name[@id=\"#{book_name}\"]/long").content

        # Save book data into database
        book = Book.find_or_create_by!(bible: bible, title: book_title, number: book_number, code: book_code)
        Rails.logger.info "Loaded Bible Book ##{book.number}: [#{book.code}] #{book.title}"

        # Read book contents
        book_relative_file_path = book_info["src"]
        book_file_path = File.join(bible_folder, book_relative_file_path)
        book_file = File.read(book_file_path)
        book_content = Nokogiri::XML(book_file)

        # Extract bible data
        chapter = nil
        heading = nil
        verse = nil
        book_content.root.children.each.with_index(1) do |segment_node, segment_node_id|
          case segment_node.node_name
          when "chapter"
            if segment_node.key?("sid")
              chapter_number = segment_node["number"].to_i
              chapter = Chapter.create!(bible: bible, book: book, number: chapter_number)
              Rails.logger.info "Loaded Bible Book ##{book.number}: [#{book.code}] #{book.title} Chapter ##{chapter.number}"
            elsif segment_node.key?("eid")
              chapter = nil
            end
          when "para"
            segment_style = segment_node["style"]

            next if Segment::HEADER_STYLES_INTRODUCTORY.include? segment_style

            section_header_styles = Segment::HEADER_STYLES_SECTIONS_MAJOR.merge(Segment::HEADER_STYLES_SECTIONS_MINOR)
            if section_header_styles.key? segment_style.to_sym
              heading_level = section_header_styles[segment_style.to_sym]
              heading = Heading.create!(bible: bible, book: book, chapter: chapter, level: heading_level, title: segment_node.text)
              Rails.logger.info "Loaded Bible Book ##{book.number}: [#{book.code}] #{book.title} Chapter ##{chapter.number} Heading #{heading.level} (#{heading.title})"
            end

            segment = Segment.create!(bible: bible, book: book, chapter: chapter, heading: heading, style: segment_style)
            Rails.logger.info "Loaded Bible Book ##{book.number}: [#{book.code}] #{book.title} Chapter ##{chapter&.number} Segment #{segment.id}"

            segment_node.children.each do |fragment_node|
              case fragment_node.node_type
              when Nokogiri::XML::Node::ELEMENT_NODE
                case fragment_node.node_name
                when "verse"
                  if fragment_node.key?("sid")
                    verse_number = fragment_node["number"].to_i
                    verse = Verse.create!(bible: bible, book: book, chapter: chapter, number: verse_number)
                    Rails.logger.info "Loaded Bible Book ##{book.number}: [#{book.code}] #{book.title} Chapter ##{chapter.number} Verse #{verse.number}"
                  elsif fragment_node.key?("eid")
                    verse = nil
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
