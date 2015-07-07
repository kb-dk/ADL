module ApplicationHelper

  def show_volume args
   link_to args[:document][args[:field]].first, solr_document_path(args[:document]['volume_id_ssi'])
  end

end
