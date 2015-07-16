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
    link_to args[:value], solr_document_path(id)
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

  # logic to create the url for the ADL facsimiles
  def img_link(vol_name, pb, prev)
    pieces = vol_name.partition(/\d.+/)
    text = pieces.first
    num = pieces[1].sub('0', '').sub(/[a-zA-Z]+/, '')
    if is_number? pb
      # "s. i" => fm001 etc
      index = pb.sub(/[a-zA-Z]/, '').rjust(3, '0')
    elsif is_roman?(pb) && (is_roman?(prev) || prev.nil?)
      n = RomanNumerals.to_decimal(pb).to_s.rjust(3, '0')
      index = 'fm' + n
    else
      # "s. a" => fm001 etc
      letters = ('a'..'z').to_a
      letter_pos = (letters.index(pb.downcase) + 1).to_s
      index = 'fm' + letter_pos.rjust(3, '0')
    end
    fname = text[0..3] + num + index
    # leaving this fail code here for now to make errors more obvious
    IMAGE_REFS[fname] || fail
  end

  def image_links(vol_name, text)
    prev = nil
    pages(text).collect do |num|
      img_link(vol_name, num.text, prev)
      prev = num
    end
  end

  def pages(text)
    xml = Nokogiri::XML(text)
    xml.xpath('//span/small/text()').to_a.collect(&:to_s)
  end

  def is_number? string
    true if Float(string) rescue false
  end

  # don't allow roman numerals larger than 100, to prevent
  # the d problem - a hack but I presume that there are no
  # introductions longer than 100 pages
  def is_roman? string
    num = RomanNumerals.to_decimal(string) rescue return
    num.between?(1, 100)
  end

  # Use regex to wrap all page breaks with links to corresponding
  # anchor in facsimile view
  def text_with_image_links(text, id)
    text.gsub(/(\[s\. <small>(\w|\d.+)<\/small>])/,'<a href="' + id + '/facsimile#\2" target="blank">\1</a>')
  end
end
