# -*- encoding : utf-8 -*-
class SolrDocument 

  include Blacklight::Solr::Document
  include Concerns::DefaultSemanticFieldValues

  # overwrite the default behaviour to enable different schema definitions
  def itemtype
    type = self['cat_ssi'] || ''
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
  # single valued. See blacklight::Document::SemanticFields#field_semantics
  # and blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  SolrDocument.use_extension(Europeana)


  #Defines the mapping from solr_fiels to Dublin Core (used by oai)
  field_semantics.merge!(
      #dc_fields
      #:contributor,
      #:coverage,
      :creator => 'author_name_ssim',
      :date => 'date_published_ssi',
      #:description,
      #:format,
      :identifier => 'id',
      #:language,
      :publisher=> 'publisher_tesim',
      #:relation,
      #:rights,
      #:source,
      #:subject,
      :title => 'work_title_tesim',
      #:type

      # :ese_dataProvider,
      :ese_isShownAt => 'url_ssi',
      #:ese_provider,
      #:ese_rights,
      #:ese_type,
      #:ese_country
  )

  default_semantic_field_values.merge!(
    :language => 'dan',
    :rights => 'Er muligvis beskyttet af loven om ophavsret',
    :type => 'Text',
    :ese_dataProvider => 'The Royal Library: The National Library of Denmark and Copenhagen University Library',
    :ese_provider => 'Arkiv for Dansk Litteratur',
    :ese_rights => 'http://creativecommons.org/licenses/by-nc-nd/4.0/',
    :ese_type => 'TEXT'
  )

#begin OAI functions
  def timestamp
    Time.parse fetch('timestamp')
  end

  def to_oai_dc
    export_as('oai_dc_xml')
  end

  def to_ese
    export_as('ese_xml')
  end
#End OAI functions

  def has_text?
    if self['text_tesim'].present?
      # some documents contain text only with line breaks
      text = self['text_tesim'].first.delete("\n")
      !text.blank?
    else
      return false
    end
  end

  def export_as_apa_citation_txt
    doc = self
    cite = ""
    cite +=  doc['author_name_ssim'].first + ", " unless doc['author_name_ssim'].blank?
    cite +=  doc['date_published_ssi'] + ", " unless doc['date_published_ssi '].blank?
    cite +=  "<i>"+doc['work_title_tesim'].first + "</i>, " unless doc['work_title_tesim'].blank?
    # check if the work is a book
    if !doc['volume_title_tesim'].blank? and doc['volume_title_tesim'] != doc['work_title_tesim']
      cite +=  I18n.t('blacklight.from') + "<i>" + doc['volume_title_tesim'].first + "</i>, "
    end
    cite +=  doc['publisher_tesim'].first + " " unless doc['publisher_tesim'].blank?
    cite +=  doc['place_published_tesim'].first unless doc['place_published_tesim'].blank?
    cite.html_safe
  end

end
