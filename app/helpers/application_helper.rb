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
  def img_link(vol_name, pb)
    pieces = vol_name.partition(/\d.+/)
    text = pieces.first
    num = pieces[1].sub('0', '').sub(/[a-zA-Z]+/, '')
    vol_dir = text + num
    fname = text[0..3] + num + pb.sub(/[a-zA-Z]/, '')
    Rails.application.config_for(:adl)['img_url'] % {vol: vol_dir, file: fname}
  end
end
