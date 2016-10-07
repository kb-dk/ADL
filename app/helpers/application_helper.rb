module ApplicationHelper

  def show_volume args
    id = args[:document]['volume_id_ssi']
    return unless id.present?
    link_to args[:value].first, solr_document_path(id)
  end

  def author_link args
    ids = args[:value]
    logger.debug "Creating author_link #{args[:document]['author_name_tesim'].to_s}"
    if (ids.is_a? Array) && (ids.size > 1) # we have more than one author
      repository = blacklight_config.repository_class.new(blacklight_config)
      ids.map!{|id| link_to get_author_name(repository,id), solr_document_path(id)}
      result=ids.to_sentence(:last_word_connector => ' og ')
    else
      if ids.is_a? Array
        author_id = ids.first
      else
        author_id = ids
      end
      author_name = args[:document]['author_name_tesim'].first if args[:document]['author_name_tesim'].present?
      author_name ||= "Intet Navn"
      result = link_to author_name, solr_document_path(author_id)
    end
    logger.debug "result is #{result}"
    result
  end

  def published_fields args
    published = []
    published << args[:document]['publisher_tesim'].first if args[:document]['publisher_tesim'].first.present?
    published << args[:document]['place_published_tesim'] if args[:document]['place_published_tesim'].present?
    published << args[:document]['date_published_ssi'] if args[:document]['date_published_ssi'].present?
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
      else
        doc
      end
    end
  end

  private

  def get_author_name repository, id
    begin
      solr_docs = repository.find(id).documents
      if solr_docs.size > 0
        solr_docs.first['work_title_tesim'].join
      else
        id
      end
    rescue Exception => e
      id
    end
  end
end
