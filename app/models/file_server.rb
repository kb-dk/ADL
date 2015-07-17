# Class to centralise inteface with FileServer
class FileServer
  def self.render_snippet(id,op=nil)
    a =id.split("#")
    uri = "#{Rails.application.config_for(:adl)["snippet_server_url"]}?doc=#{a[0]}.xml"
    uri += "&id=#{a[1]}" unless a.size < 2
    uri += "&op=#{op}" unless op.nil?
    Rails.logger.debug("url #{uri}")
    res = Net::HTTP.get_response(URI(uri))
    if (res.code == "200")
      result = res.body
    else
      result ="<div class='error'>Unable to connect to snippet server #{uri}</div>"
    end
    result.html_safe.force_encoding('UTF-8')
  end

  # Using the data in the images file, find the correct href for the facsimile
  # This is a heavy operation! A better solution would be to correct the attributes
  # in the TEI / HTML to prevent the large number of Hash lookups.
  # Note that we use data-src here in concert with the jQuery Unveil plugin
  # to lazy load our images
  def self.render_facsimile(id)
    html = FileServer.render_snippet(id, 'facsimile')
    xml = Nokogiri::HTML(html)
    xml.css('img').each do |img|
      img['src'] = 'images/default.gif'
      img['data-src'] = IMAGE_REFS.fetch img['data-src'], 'images/default.gif'
    end
    xml.to_xml
  end
end