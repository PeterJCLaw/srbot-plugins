class BudgetPlugin < Plugin
  
  # return a help string when the bot is asked for help on this plugin
  def help(plugin, topic="")
    return "budget => What's the total of the SR2012 budget so far."
  end
  
  # reply to a private message that we've registered for
  def privmsg(m)

    p = `GET http://optimusprime.studentrobotics.org/~rbarlow/budget/?simple=abc`

    m.reply "The budget for SR2012 is £#{p}"
  end
end

plugin = BudgetPlugin.new
plugin.register("budget")
