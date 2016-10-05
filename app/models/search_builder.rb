class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr]

  self.default_processor_chain += [:add_work_id]

  def add_work_id solr_params
    if blacklight_params[:search_field] == 'leaf' && blacklight_params[:workid].present?
      solr_params[:fq] ||= []
      workid = blacklight_params[:workid]
      workid = "#{workid}*" unless workid.include? '*'
      solr_params[:fq] << "part_of_ssim:#{workid}"
    end
  end

  def restrict_to_works solr_params
    solr_params[:fq] ||= []
    solr_params[:fq] << "cat_ssi:work"
  end

  def add_timestamp_interval solr_params
    timeinterval_string = '['+ (blacklight_params[:from].present? ? blacklight_params[:from] : '*')
    timeinterval_string += ' TO '
    timeinterval_string += (blacklight_params[:until].present? ? blacklight_params[:until] : '*') +']'
    solr_params[:fq] ||= []
    solr_params[:fq] << "timestamp:#{timeinterval_string}"
  end
end
