# Class to centralise inteface with FileServer
class FileServer
  def self.render_snippet(id,op=nil)
    a =id.split("#")
    uri = "#{Rails.application.config_for(:adl)["snippet_server_url"]}?doc=#{a[0]}.xml"
    uri += "&id=#{a[1]}" unless a.size < 2
    uri += "&op=#{op}" unless op.nil?
    Rails.logger.debug("url #{uri}")

    #res = Net::HTTP.get_response(URI(uri))
    uri = URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 10
    http.read_timeout = 20
    begin
      res = http.start { |conn| conn.request_get(URI(uri)) }
      if res.code == "200"
        result = res.body
      else
        result ="<div class='alert alert-danger'>Unable to connect to data server</div>"
      end
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      Rails.logger.error "Could not connect to #{uri}"
      Rails.logger.error e
      result ="<div class='alert alert-danger'>Unable to connect to data server</div>"
    end

    result.html_safe.force_encoding('UTF-8')
  end

  # Using the data in the images file, find the correct href for the facsimile
  # This is a heavy operation! A better solution would be to correct the attributes
  # in the TEI / HTML to prevent the large number of Hash lookups.
  # Note that we use data-src here in concert with the jQuery Unveil plugin
  # to lazy load our images
  def self.render_facsimile(id)
    html = FileServer.facsimile(id)
    xml = Nokogiri::HTML(html)
    # we use the path_to_image helper here to insert a loading gif
    # we need to use the helper to take care of watermarking for us
    loading_image = ActionController::Base.helpers.path_to_image('default.gif')
    xml.css('img').each do |img|
        img['src'] = loading_image
        img['data-src'] = ImageServer.ref_to_url(img['data-src'], loading_image)
      end
    xml.to_xml
  end

  # return all image links for use in facsimile pdf view
  def self.image_links(id)
    html = FileServer.facsimile(id)
    xml = Nokogiri::HTML(html)
    links = []
    xml.css('img').each do |img|
      links << ImageServer.ref_to_url(img['data-src'], '')
    end
    links
  end

  def self.facsimile(id)
    FileServer.render_snippet(id, 'facsimile')
  end
end