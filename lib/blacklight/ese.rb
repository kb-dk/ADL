module Blacklight
  class Ese < ::OAI::Provider::Metadata::Format
    def initialize
      @prefix = 'ese'
      @schema = 'http://www.europeana.eu/schemas/ese/'
      @namespace = 'http://www.europeana.eu/schemas/ese/'
      @element_namespace = 'europeana'
      @fields = [ :title, :creator, :subject, :description, :publisher,
                  :contributor, :date, :type, :format, :identifier,
                  :source, :language, :relation, :coverage, :rights]
    end

    def header_specification
      {
          'xmlns' => 'http://www.europeana.eu/schemas/ese/',
          'xmlns:oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
          'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
          'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
          'xsi:schemaLocation' =>
              %{http://www.openarchives.org/OAI/2.0/oai_dc/
              http://www.openarchives.org/OAI/2.0/oai_dc.xsd
              http://www.europeana.eu/schemas/ese/}.gsub(/\s+/, ' ')
      }
    end
  end
end