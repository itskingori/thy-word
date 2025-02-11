# frozen_string_literal: true

class PagesController < ApplicationController
  def home
    @bible = Bible.find_by! code: "BSB"
    @book = Book.find_by! bible: @bible, code: "GEN"
    @chapter = Chapter.find_by! bible: @bible, book: @book, number: 1
    @segments = Segment.where(bible: @bible, book: @book, chapter: @chapter).order(created_at: :asc)

    @footnotes_mapping = {}
    @footnotes = Footnote.where(bible: @bible, book: @book, chapter: @chapter).order(created_at: :asc)
    @footnotes.each.with_index(1) { |footnote, footnote_number| @footnotes_mapping[footnote.id] = footnote_number  }
  end
end
