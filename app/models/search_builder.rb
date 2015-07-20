class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  def add_work_id solr_params
    if blacklight_params[:search_field] == 'leaf' && blacklight_params[:workid].present?
      solr_params[:fq] ||= []
      workid = blacklight_params[:workid]
      workid = "#{workid}*" unless workid.include? '*'
      solr_params[:fq] << "part_of_ssi:#{workid}"
    end
  end
end
