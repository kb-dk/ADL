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

  def render_snippet(id,op=nil)
    a =id.split("#")
    uri = "#{Rails.application.config_for(:adl)["snippet_server_url"]}?doc=#{a[0]}.xml"
    uri += "&id=#{a[1]}" unless a.size < 2
    uri += "&op=#{op}" unless op.nil?
    logger.debug("url "+uri)
    res = Net::HTTP.get_response(URI(uri))
    result = ''
    if (res.code == "200")
      result = res.body
    else
      result ="<div class='error'>Unable to connect to snippet server #{uri}</div>"
    end
    result.html_safe.force_encoding('UTF-8')
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
end
