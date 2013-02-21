
require 'open-uri'
require 'openssl'

#disable ssl verification
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class SRLinksPlugin < Plugin
  TracURL = "http://trac.srobo.org/"
  SafeTracUrl = "https://www.studentrobotics.org/trac/"
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
      match_id = match[2].to_s
      if not (baseURL == TracURL + "ticket/%s") or ticket_exists?(match_id)
        m.reply baseURL % match_id
        return true
      end
    end
  end

  # create a link to any ticket numbers present
  def link_ticket(m)
    if match = /(^|\s)#(\d+)($|\s)/.match(m.message)
      match_id = match[2].to_s
      m.reply(ticket_url(match_id)) if ticket_exists?(match_id)
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

  private

  def ticket_exists?(ticket_id)
    begin
      io = open(safe_ticket_url(ticket_id))
      true
    rescue OpenURI::HTTPError
      false
    end
  end

  def ticket_url(ticket_id)
    "#{TracURL}#{ticket_suffix(ticket_id)}"
  end

  def safe_ticket_url(ticket_id)
    "#{SafeTracUrl}#{ticket_suffix(ticket_id)}"
  end

  def ticket_suffix(ticket_id)
    "ticket/#{ticket_id}"
  end
end

# create an instance of our plugin class and register for our commands
plugin = SRLinksPlugin.new
plugin.register("trac")
