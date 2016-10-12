class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  self.default_processor_chain += [:restrict_to_author_id]

  def restrict_to_author_id solr_params
    if (blacklight_params[:authorid].present?)
      solr_params[:fq] ||= []
      solr_params[:fq] << "author_id_ssim:#{blacklight_params[:authorid]}"
    end
  end

  def part_of_volume_search solr_params
    solr_params[:fq] = []
    solr_params[:fq] << "cat_ssi:work"
    solr_params[:fq] << "volume_id_ssi:#{blacklight_params[:volumeid]}"
    solr_params[:rows] = 10000

  end

  def build_all_authors_search solr_params = {}
    solr_params[:fq] = []
    solr_params[:fq] << 'cat_ssi:author'
    solr_params[:fq] << 'type_ssi:work'
    solr_params[:sort] = []
    solr_params[:sort] << 'id asc'
    solr_params[:rows] = 10000
  end

  def add_timestamp_interval solr_params
    timeinterval_string = '['+ (blacklight_params[:from].present? ? blacklight_params[:from] : '*')
    timeinterval_string += ' TO '
    timeinterval_string += (blacklight_params[:until].present? ? blacklight_params[:until] : '*') +']'
    solr_params[:fq] ||= []
    solr_params[:fq] << "timestamp:#{timeinterval_string}"
  end
end
