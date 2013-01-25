
require 'open-uri'

class SRLinksPlugin < Plugin
  TracURL = "http://trac.srobo.org/"
  GerritURL = "http://gerrit.srobo.org/%s"
  RepoURL = "http://srobo.org/cgit/%s.git"

  NumRegex = "(\\d+)"
  # A bit more than ordinary words..
  WordsRegex = "([\\w/\\-]+)"
  RepoRegex = WordsRegex + "(.git)?"

  PrefixMapping = Hash[
    "#" + NumRegex => TracURL + "ticket/%s",
    "g:" + NumRegex => GerritURL,
    "gerrit:" + NumRegex => GerritURL,
    "git:" + RepoRegex => RepoURL,
    "cgit:" + RepoRegex => RepoURL
  ]

  # return a help string when the bot is asked for help on this plugin
  def help(plugin, topic="")
    return "trac <page|ticket> => return a link to the page or ticket"
  end

  # create a link based on a pair of options from our hash
  def link_pair(m, partialRegex, baseURL)
    #print partialRegex, "\n"
    fullRegex = /(^|\s)#{partialRegex}($|\s)/
    #print fullRegex, "\n"
    if match = fullRegex.match(m.message)
      #print match
      match_id = match[2]
      m.reply baseURL % match_id.to_s
      return true
    end
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

    #print m.message, "\n"
    PrefixMapping.each {|partialRegex, baseURL|
      link_pair(m, partialRegex, baseURL)
    }

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
