# encoding: utf-8

# Hack needed to let the require 'fetch.rb' work outside rbot as well as in.
$LOAD_PATH << '.'

require './fetch.rb'

class WorthPlugin < Plugin

  # return a help string when the bot is asked for help on this plugin
  def help(plugin, topic="")
    return "worth => Say how much SR is worth."
  end

  # reply to a private message that we've registered for
  def privmsg(m)

    p = optimus_fetch('~rbarlow/worth/?simple=abc')

    m.reply "SR is worth £#{p}"
  end
end

plugin = WorthPlugin.new
plugin.register("worth")
