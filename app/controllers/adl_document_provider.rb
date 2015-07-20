class AdlDocumentProvider < ::OAI::Provider::Base
  repository_name 'Adl OAI provider'
  repository_url  'http://localhost/provider'
  record_prefix ''
  admin_email 'root@localhost'   # String or Array
  def initialize controller
    w = ::AdlDocumentWrapper.new controller
    self.class.model = w
  end
end