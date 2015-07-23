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

  def has_text?
    if self.to_hash['text_tesim'].present?
      # some documents contain text only with line breaks
      text = self.to_hash['text_tesim'].first.delete("\n")
      !text.blank?
    else
      return false
    end
  end

  def export_as_apa_citation_txt
    doc = self.to_hash
    cite = ""
    cite += doc['author_name'].first + ". " unless doc['author_name'].blank?
    cite += "("+ doc['published_date_ssi'] + "). " unless doc['published_date_ssi'].blank?
    cite +=  doc['work_title_tesim'].first + ". " unless doc['work_title_tesim'].blank?
    cite +=  I18n.t('blacklight.retrieve') + doc['volume_title_tesim'].first + ". " unless doc['volume_title_tesim'].blank?
    cite +=  doc['published_place_ssi'] + ": " unless doc['published_place_ssi'].blank?
    cite +=  doc['publisher_ssi'] + ". " unless doc['publisher_ssi'].blank?
    cite.html_safe
  end

end
