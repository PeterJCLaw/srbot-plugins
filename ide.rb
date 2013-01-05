
require 'rubygems'

require 'json'
require 'net/https'
require 'time'

class IDEPlugin < Plugin

  # return a help string when the bot is asked for help on this plugin
  def help(plugin, topic="")
    return "ide => returns the status of the IDE"
  end

  # reply to a private message that we've registered for
  def privmsg(m)
	message = version
	m.reply message
  end

  # Replies with the currently live IDE version
  def version
	base_url = 'https://www.studentrobotics.org/ide/'
	url = "#{base_url}control.php/info/about"
	uri = URI.parse(url)

	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE

	request = Net::HTTP::Get.new(uri.request_uri)
	resp = http.request(request)
	data = resp.body

	result = JSON.parse(data)
	version = result['info']['Version']
	version = version[0..-7]

	return "At version: #{version}"
  end
end

# create an instance of our plugin class and register for the "length" command
plugin = IDEPlugin.new
plugin.register("ide")
