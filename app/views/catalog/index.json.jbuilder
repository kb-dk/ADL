#overwritten to get highlighting included in the json results
json.response do
  json.docs @presenter.documents
  json.facets @presenter.search_facets_as_json
  json.pages @presenter.pagination_info
  json.highlighting @response["highlighting"]
end
