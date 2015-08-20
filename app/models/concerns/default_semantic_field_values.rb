module Concerns
  module DefaultSemanticFieldValues
    extend ActiveSupport::Concern

    # adds a list of default semantic field values solr_doc
    # only used by Europeana OAI for now

    module ClassMethods
      def default_semantic_field_values
        @default_semantic_field_values ||= {}
      end
    end

  end
end
