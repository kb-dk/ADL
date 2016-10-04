module ApplicationHelper

  def show_volume args
    id = args[:document]['volume_id_ssi']
    return unless id.present?
    link_to args[:value].first, solr_document_path(id)
  end

  def author_link args
    repository = blacklight_config.repository_class.new(blacklight_config)
    ids = args[:value]
    ids.map!{|id| link_to repository.find(id).documents.first['work_title_tesim'].join, solr_document_path(id)}
    ids.to_sentence(:last_word_connector => ' og ')
  end

  def published_fields args
    publisher = args[:document]['publisher_ssi']
    published_place = args[:document]['published_place_ssi']
    published_date = args[:document]['published_date_ssi']
    # check if there are nil values in the array
    published = [publisher, published_place, published_date].reject { |c| c.nil? }
    published = published.join(', ')
    published.html_safe
  end

  def translate_model_names(name)
    I18n.t("models.#{name}")
  end

  def present_snippets args
    val = args[:value]
    return unless val.present?
    term_freq = args[:document]['termfreq(text_tesim, $q)']
    snippets = ('...' + val.join('...<br/>...'))
    "<strong>#{term_freq} fund:</strong><br/> #{snippets}".html_safe
  end

  def search_type_link(type, label)
    link_to label, '#', data: { search_type: type,  no_turbolink: true }
  end

  # Generic method to create glyphicon icons
  # supply only the last component of the icon name
  # e.g. 'off', 'cog' etc
  def bootstrap_glyphicon(icon, classes = '')
    content_tag(:span, nil, class: "glyphicon glyphicon-#{icon} #{classes}").html_safe
  end

  def author_portrait_search_link(firstname,lastname,label)
    link_to label, "/?f[cat_ssi][]=portrait&search_field=Alle+Felter&q=#{firstname}+#{lastname}"
  end

  def author_work_facet_link(firstname,lastname,label)
    name = ''
    name += lastname if lastname.present?
    name += ', ' if name.present?
    name += firstname if firstname.present?
    link_to label, "/?f[author_ssi][]=#{URI.escape(name)}"
  end

  module Blacklight::UrlHelperBehavior
  ##
  # Extension point for downstream applications
  # to provide more interesting routing to
  # documents
    def url_for_document doc, options = {}
      if respond_to?(:blacklight_config) and
          blacklight_config.show.route and
          (!doc.respond_to?(:to_model) or doc.to_model.is_a? SolrDocument)
        route = blacklight_config.show.route.merge(action: :show, id: doc).merge(options)
        route[:controller] = controller_name if route[:controller] == :current
        route
      elsif doc.present? && doc['cat_ssi'] == 'person'
        { controller: :people, action: :show, id: doc }
      else
        doc
      end
    end
  end

end
