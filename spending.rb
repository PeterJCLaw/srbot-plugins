class SpendingPlugin < Plugin
  
  # return a help string when the bot is asked for help on this plugin
  def help(plugin, topic="")
    return "spending => How much of the budget have we spent?"
  end
  
  # reply to a private message that we've registered for
  def privmsg(m)

    p = `GET https://optimusprime.studentrobotics.org/~rbarlow/spending/?simple=abc`

    m.reply "So far we've spent #{p}"
  end
end

plugin = SpendingPlugin.new
plugin.register("spending")
