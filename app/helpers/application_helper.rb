require 'net/http'

module ApplicationHelper

  def show_volume args
    id = args[:document]['volume_id_ssi']
    return unless id.present?
    link_to args[:value].first, solr_document_path(id)
  end

  def author_link args
    id = args[:document]['author_id_ssi']
    return unless id.present?
    link_to args[:value], controller: "people", action: "show", id: id
  end

  def published_fields args
    publisher = args[:document]['publisher_ssi']
    published_date = args[:document]['published_date_ssi']
    published = ""
    published += publisher if publisher.present?
    published += ", " if publisher.present? and published_date.present?
    published += published_date if published_date.present?
    published.html_safe
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

  def pages(text)
    xml = Nokogiri::XML(text)
    xml.xpath('//span/a/small/text()').to_a.collect(&:to_s)
  end

  # correct image links from served HTML
  # Note the no turbolink rule to enable unveil plugin to work properly
  def text_with_image_links(text, id)
   text.gsub('a href="/facsimile', "a data-no-turbolink=\"true\" href=\"/catalog/#{id}/facsimile")
  end

  # Generic method to create glyphicon icons
  # supply only the last component of the icon name
  # e.g. 'off', 'cog' etc
  def bootstrap_glyphicon(icon, classes = '')
    content_tag(:span, nil, class: "glyphicon glyphicon-#{icon} #{classes}").html_safe
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
