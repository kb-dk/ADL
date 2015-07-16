# -*- encoding : utf-8 -*-
class SolrDocument 

  include Blacklight::Solr::Document

  # overwrite the default behaviour to enable different schema definitions
  def itemtype
    type = self.to_hash['cat_ssi'] || ''
    case type
      when 'work'
        'http://schema.org/CreativeWork'
      when 'person'
        'http://schema.org/Person'
      else
        'http://schema.org/Thing'
    end
  end

  # self.unique_key = 'id'
  
  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Document::Email )
  
  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Document::DublinCore)


  field_semantics.merge!(
      #dc_fields
      #:contributor,
      #:coverage,
      :creator => 'author_name',
      #:date,
      #:description,
      #:format,
      :identifier => 'id',
      #:language,
      :publisher=> 'publisher_ssi',
      #:relation,
      #:rights,
      #:source,
      #:subject,
      :title => 'work_title_tesim',
      #:type
  )

end
