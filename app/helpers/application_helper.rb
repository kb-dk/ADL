module ApplicationHelper

  def show_volume args
    link_to args[:document][args[:field]].first, solr_document_path(args[:document]['volume_id_ssi'])
  end


  def present_snippets args
    val = args[:value]
    return unless val.present?
    term_freq = args[:document]['termfreq(text_tesim, $q)']
    snippets = ('...' + val.join('...<br/>...'))
    "<strong>#{term_freq} fund:</strong><br/> #{snippets}".html_safe
  end
end
