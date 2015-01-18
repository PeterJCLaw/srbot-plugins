
import urllib

TRAC_URL = "http://trac.srobo.org/"
GERRIT_URL = "http://gerrit.srobo.org/{0}"
REPO_URL = "http://srobo.org/cgit/{0}.git"

NUM_PATTERN = r"(\d+)\b"
# A bit more than ordinary words..
WORDS_PATTERN = r"([\w/\-]+)"
REPO_PATTERN = r"(([\w\-]+/?)+)(.git)?"

def wrap(d):
    out = {}
    for pattern, val in d.items():
        out['.*' + pattern + '.*'] = val
    return out

def ticket_exists(num):
    # TODO
    return True

patterns = wrap({
                "#" + NUM_PATTERN: (TRAC_URL + "ticket/{0}", ticket_exists),
            r"\bg:" + NUM_PATTERN: GERRIT_URL,
       r"\bgerrit:" + NUM_PATTERN: GERRIT_URL,
         r"\bgit:" + REPO_PATTERN: REPO_URL,
        r"\bcgit:" + REPO_PATTERN: REPO_URL,
})

class SRLinks(object):
    def __init__(self, patterns):
        self.__name__ = self.__class__.__name__
        self._patterns = patterns
        self.rule = list(patterns.keys())

    def __call__(self, bot, trigger):
        pattern = trigger.match.re.pattern
        try:
            response = self._patterns[pattern]
        except KeyError:
            bot.debug("Unexpected pattern {0}.".format(repr(pattern)))
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

srlinks = SRLinks(patterns)
