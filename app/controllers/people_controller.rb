class PeopleController < CatalogController

  # Add new search behavior by adding a Symbol with the name of a relevant method.
  # The search_params_logic takes one argument: the hash of solr_parameters and modifies
  # the solr_parameters directly, as needed.
  self.search_params_logic += [:restrict_to_author]

  def restrict_to_author(solr_params, *args)
    author_id = params[:id]
    solr_params[:fq] ||= []
    solr_params[:fq] << "author_id_ssi:#{author_id}"
  end

  def show
    super
    (response, document_list) = search_results({}, search_params_logic)
    @genres = Hash[*response['facet_counts']['facet_fields']['genre_ssi']]
  end

end