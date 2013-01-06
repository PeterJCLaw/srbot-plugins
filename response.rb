class ResponsePlugin < Plugin
  
  # return a help string when the bot is asked for help on this plugin
  def help(plugin, topic="")
    return "response => Show stats on the forum support response time."
  end
  
  # reply to a private message that we've registered for
  def privmsg(m)

    p = `GET http://optimusprime.studentrobotics.org/~rbarlow/forum_response_time/?simple=abc`

    m.reply "#{p}"
  end
end

plugin = ResponsePlugin.new
plugin.register("response")
