
import urllib

trac_url = 'http://trac.srobo.org'
wiki_url = trac_url + '/wiki/{0}'
ticket_url = trac_url + '/ticket/{0}'

class FooBar(object):
    def __init__(self):
        self.__name__ = self.__class__.__name__
        self.rule = ['foo']

    def __call__(self, bot, trigger):
        bot.say("bar")

def ticket_exists(num):
    # TODO
    return True

patterns = {
    r'.*#(\d+).*': (ticket_url, ticket_exists)
}

class SRLinks(object):
    def __init__(self, patterns):
        self.__name__ = self.__class__.__name__
        self._patterns = patterns
        self.rule = list(patterns.keys())
        print(self.rule)

    def __call__(self, bot, trigger):
        pattern = trigger.match.re.pattern
        try:
            response = self._patterns[pattern]
        except KeyError:
            bot.debug("Unexpected pattern '{0}'.".format(repr(pattern)))
            return

        if isinstance(response, tuple):
            response, check = response
        else:
            check = None

        match = trigger.group(1)
        if not check or check(match):
            quoted = urllib.quote(match)
            formatted = response.format(quoted)
            bot.say(formatted)

#foo = FooBar()
srlinks = SRLinks(patterns)
