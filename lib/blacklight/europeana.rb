require 'builder'

# This is an extended version for the blacklight Dublin Core extenstion
# Extended with Europeana fields

module Europeana


  def self.extended(document)
    # Register our exportable formats
    ::Europeana.register_export_formats( document )
  end

  def self.register_export_formats(document)
    document.will_export_as(:xml)
    document.will_export_as(:dc_xml, "text/xml")
    document.will_export_as(:oai_dc_xml, "text/xml")
  end

  def default_field_values
    def field_semantics
      @default_field_values ||= {}
    end
  end

  def dublin_core_field_names
    [:contributor,
     :coverage,
     :creator,
     :date,
     :description,
     :format,
     :identifier,
     :language,
     :publisher,
     :relation,
     :rights,
     :source,
     :subject,
     :title,
     :type]
  end

  def europeana_field_names
    [:ese_dataProvider,
     :ese_isShownAt,
     :ese_provider,
     :ese_rights,
     :ese_type,
     :ese_country]
  end

  def export_as_oai_dc_xml
    xml = Builder::XmlMarkup.new
    xml.tag!("oai_dc:dc",
             'xmlns:oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
             'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
             'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
             'xsi:schemaLocation' => %{http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd}) do
      add_dc_data(xml)
    end
    xml.target!
  end

  def export_as_ese_xml
    xml = Builder::XmlMarkup.new
    xml.tag!("record",
             "xmlns:europeana" => "http://www.europeana.eu/schemas/ese/",
             'xmlns:oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
             'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
             'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
             'xmlns:dcterms' => "http://purl.org/dc/terms/",
             'xmlns' => "http://www.europeana.eu/schemas/ese/",
             'xsi:schemaLocation' => %{http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd http://www.europeana.eu/schemas/ese/}) do
      add_dc_data(xml)
      add_ese_data(xml)
    end
    xml.target!
  end

  alias_method :export_as_xml, :export_as_oai_dc_xml
  alias_method :export_as_dc_xml, :export_as_oai_dc_xml
  alias_method :export_as_ese, :export_as_ese_xml


  private

  def add_dc_data(xml)
    data = add_default_dc_values(self.to_semantic_values.select { |field, values| dublin_core_field_name? field  })
    data.each do |field,values|
      Array.wrap(values).each do |v|
        xml.tag! "dc:#{field}", v
      end
    end
  end

  def add_ese_data(xml)
    data = add_default_ese_values(self.to_semantic_values.select { |field, values| europeana_field_name? field  })
    data.each do |field,values|
      Array.wrap(values).each do |v|
        xml.tag! "europeana:#{field.to_s.gsub(/^.*_/,'')}", v
      end
    end
  end

  def dublin_core_field_name? field
    dublin_core_field_names.include? field.to_sym
  end

  def europeana_field_name? field
    europeana_field_names.include? field.to_sym
  end

  def add_default_dc_values(values)
    dublin_core_field_names.each do |field|
      if values[field].blank? && SolrDocument::default_semantic_field_values[field].present?
        values[field] = SolrDocument::default_semantic_field_values[field]
      end
    end
    values
  end

  def add_default_ese_values(values)
    europeana_field_names.each do |field|
      if values[field].blank? && SolrDocument::default_semantic_field_values[field].present?
        values[field] = SolrDocument::default_semantic_field_values[field]
      end
    end
    values
  end
end
