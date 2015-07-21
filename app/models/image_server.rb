# Class for handling interaction with IIIF image server
# This should probably be expanded and possibly gemified to
# enable sharing of a common interface.
class ImageServer

  # Given a path to a file, return a path to a view of it
  # the interface allows the caller to configure the request API, but it defaults to full native views
  # {scheme}://{server}{/prefix}/{identifier}/{region}/{size}/{rotation}/{quality}.{format}
  # See http://iiif.io/api/image/2.0/#image-request-uri-syntax for details
  def self.filepath_to_url(path, options = {})
    defaults = { region: 'full', size: 'full', rotation: '0', quality: 'native', format: 'jpg' }
    options = defaults.merge(options)
    syntax = '/%{region}/%{size}/%{rotation}/%{quality}.%{format}' % options
    path + syntax
  end

  def self.ref_to_url(path, default_img, options = {})
    path = IMAGE_REFS.fetch(path, default_img)
    self.filepath_to_url(path, options)
  end
end