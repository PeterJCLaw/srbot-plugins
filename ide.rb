
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
	message = version + "\n" + last_request
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

  # Replies with the time of the last request, per the IDE's log.
  def last_request

	ide_log = '/tmp/ide-log'
	if not File.readable?(ide_log)
		return "unknown"
	end

	time = File.mtime(ide_log)

	if time == nil
		return "unknown"
	end

	difference = Time.now() - time

	last = time.strftime('%a, %b %d %Y %H:%M:%S')


	if difference > 180
		diff = Integer(difference / 60)
		diff = "#{diff} minutes ago on"
	else
		diff = Integer(difference)
		diff = "#{diff} second(s) ago on"
	end

	message = "Last error: #{diff} #{last}"

	return message

  end
end

# create an instance of our plugin class and register for the "length" command
plugin = IDEPlugin.new
plugin.register("ide")
