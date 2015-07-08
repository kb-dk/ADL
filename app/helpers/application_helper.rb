module ApplicationHelper

  def show_volume args
    id = args[:document]['volume_id_ssi']
    return unless id.present?
    link_to args[:value].first, solr_document_path(id)
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
