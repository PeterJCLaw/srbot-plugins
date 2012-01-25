require 'time'

class IDEPlugin < Plugin

  # return a help string when the bot is asked for help on this plugin
  def help(plugin, topic="")
    return "ide => returns the status of the IDE"
  end

  # reply to a private message that we've registered for
  def privmsg(m)
	m.reply last_request
  end

  # Replies with the time of the last request, per the IDE's log.
  def last_request

	ide_log = '/tmp/ide-log'
	if not File.readable?(ide_log)
		return "unknown"
	end

	f = File.open(ide_log)
	last = f.readlines[-1]
	f.close()

	last = /D = ([^,]+)/.match(last)[1]
	last = last[0..-8]

	time = Time.parse(last)

	difference = Time.now() - time

	message = "Last request: #{last}, "

	if difference > 180
		diff = Integer(difference / 60)
		message = "#{message}#{diff} minutes ago"
	else
		diff = Integer(difference / 60)
		message = "#{message}#{diff} second(s) ago"
	end

	return message

  end
end

# create an instance of our plugin class and register for the "length" command
plugin = IDEPlugin.new
plugin.register("ide")
