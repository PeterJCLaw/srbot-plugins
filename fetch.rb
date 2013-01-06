
require 'rubygems'

require 'net/https'

def optimus_fetch(relative_path)
  url = "https://optimusprime.studentrobotics.org/#{relative_path}"
  uri = URI.parse(url)

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri)
  resp = http.request(request)
  data = resp.body

  return data
end
