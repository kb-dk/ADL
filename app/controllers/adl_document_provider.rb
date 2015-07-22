=begin
  Setup at ADL OAI provider
=end
class AdlDocumentProvider < ::OAI::Provider::Base
  repository_name 'Adl OAI provider'
  repository_url  'http://www.adl.dk'
  record_prefix ''
  admin_email 'root@localhost'   # String or Array
  def initialize controller
    w = ::AdlDocumentWrapper.new controller
    self.class.model = w
  end
end