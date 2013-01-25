
require 'open-uri'

class SRLinksPlugin < Plugin
  TracURL = "http://trac.srobo.org/"

  # return a help string when the bot is asked for help on this plugin
  def help(plugin, topic="")
    return "trac <page|ticket> => return a link to the page or ticket"
  end

  # create a link to any ticket numbers present
  def link_ticket(m)
    if match = /(^|\s)#(\d+)($|\s)/.match(m.message)
      match_id = match[2]
      m.reply TracURL + "ticket/" + match_id.to_s
      return true
    end
  end

  # listen to the whole channel
  def listen(m)
    unless(m.is_a? PrivMessage)
      return
    end

    if /^trac /.match(m.message)
      return
    end

    if link_ticket(m)
      return
    end

  end

  # reply to a private message that we've registered for
  def privmsg(m)
    if link_ticket(m)
      return
    end

    page = m.message[4..-1].strip
    if /\d+/.match(page)
      m.reply TracURL + "ticket/" + page
      return
    end

    m.reply TracURL + "wiki/" + URI::encode(page)
  end
end

# create an instance of our plugin class and register for our commands
plugin = SRLinksPlugin.new
plugin.register("trac")
