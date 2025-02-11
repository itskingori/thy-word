namespace :bible do
  namespace :bsb do
    task import: :environment do
      Rails.logger = Logger.new(STDOUT)
      Rails.logger.level = Logger::INFO

      # Destory bible data
      Footnote.destroy_all
      Fragment.destroy_all
      Segment.destroy_all
      Verse.destroy_all
      Heading.destroy_all
      Chapter.destroy_all
      Book.destroy_all
      Bible.destroy_all

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
          next unless book.code == "GEN" # TODO: Remove

          show_verse = false

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
              fragment_text = fragment_node.text.strip
              fragment_kind = nil

              case fragment_node.node_type
              when Nokogiri::XML::Node::ELEMENT_NODE
                case fragment_node.node_name
                when "ref"
                  fragment_kind = "reference"
                when "note"
                  fragment_kind = "note"
                  footnote_text = fragment_node.children.select { |note_child_node| note_child_node.node_name == "char" && note_child_node['style'] == "ft" }.first.text.strip
                  footnote = Footnote.create!(bible: bible, book: book, chapter: chapter, verse: verse, content: footnote_text)
                  fragment_text = "#{footnote.id}"
                  Rails.logger.info "Loaded Bible Book ##{book.number}: [#{book.code}] #{book.title} Chapter ##{chapter.number} Verse #{verse.number} Footnote #{footnote.id}"
                when "verse"
                  if fragment_node.key?("sid")
                    show_verse = true
                    verse_number = fragment_node["number"].to_i
                    verse = Verse.create!(bible: bible, book: book, chapter: chapter, number: verse_number)
                    Rails.logger.info "Loaded Bible Book ##{book.number}: [#{book.code}] #{book.title} Chapter ##{chapter.number} Verse #{verse.number}"
                  elsif fragment_node.key?("eid")
                    verse = nil
                  end
                end
              when Nokogiri::XML::Node::TEXT_NODE
                fragment_kind = "text"
              end

              next if fragment_text.empty?

              fragment = Fragment.create!(bible: bible, book: book, segment: segment, chapter: chapter, heading: heading, verse: verse, kind: fragment_kind, show_verse: show_verse, content: fragment_text)
              show_verse = false if fragment.show_verse
              Rails.logger.info "Loaded Bible Book ##{book.number}: [#{book.code}] #{book.title} Chapter ##{chapter&.number} Segment #{segment.id} Fragment #{fragment.id} (#{fragment.content})"
            end
          end
        end
      end
    end
  end
end
