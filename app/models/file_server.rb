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
end