require 'net/http'

module ApplicationHelper

  def show_volume args
    id = args[:document]['volume_id_ssi']
    return unless id.present?
    link_to args[:value].first, solr_document_path(id)
  end

  def author_link args
    id = args[:document]['author_id_ssi']
    return unless id.present?
    link_to args[:value], controller: "people", action: "show", id: id
  end

  def published_fields args
    publisher = args[:document]['publisher_ssi']
    published_date = args[:document]['published_date_ssi']
    published = ""
    published += publisher if publisher.present?
    published += ", " if publisher.present? and published_date.present?
    published += published_date if published_date.present?
    published.html_safe
  end

  def present_snippets args
    val = args[:value]
    return unless val.present?
    term_freq = args[:document]['termfreq(text_tesim, $q)']
    snippets = ('...' + val.join('...<br/>...'))
    "<strong>#{term_freq} fund:</strong><br/> #{snippets}".html_safe
  end

  def search_type_link(type, label)
    link_to label, '#', data: { search_type: type,  no_turbolink: true }
  end

  def pages(text)
    xml = Nokogiri::XML(text)
    xml.xpath('//span/a/small/text()').to_a.collect(&:to_s)
  end

  def first_page_link(text)
    '#s' + pages(text).first unless pages(text).empty?
  end

  # correct image links from served HTML
  # Note the no turbolink rule to enable unveil plugin to work properly
  def text_with_image_links(text, id)
   text.gsub('a href="/facsimile', "a data-no-turbolink=\"true\" href=\"/catalog/#{id}/facsimile")
  end
end
