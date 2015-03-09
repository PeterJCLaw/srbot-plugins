
from __future__ import print_function

import re
import urllib

TRAC_URL = "http://trac.srobo.org/"
GERRIT_URL = "http://gerrit.srobo.org/{0}"
REPO_URL = "http://srobo.org/cgit/{0}.git"

NUM_PATTERN = r"(\d+)\b"
# A bit more than ordinary words..
WORDS_PATTERN = r"([\w/\-]+)"
REPO_PATTERN = r"(([\w\-]+/?)+)(.git)?"

def to_search(pattern):
    return '.*' + pattern + '.*'

def ticket_exists(num):
    # TODO
    return True

patterns = {
                "#" + NUM_PATTERN: (TRAC_URL + "ticket/{0}", ticket_exists),
            r"\bg:" + NUM_PATTERN: GERRIT_URL,
       r"\bgerrit:" + NUM_PATTERN: GERRIT_URL,
         r"\bgit:" + REPO_PATTERN: REPO_URL,
        r"\bcgit:" + REPO_PATTERN: REPO_URL,
}

class SRLinks(object):
    def __init__(self, patterns):
        self.__name__ = self.__class__.__name__
        keys = patterns.keys()
        # Build the list of rules for Willie, converting the search
        # patterns into patterns which will match a whole line
        self.rule = list(map(to_search, keys))
        # Compile the search patterns so that they can later be used
        # to search the line again to pick up duplicates
        compiled = map(re.compile, keys)
        compiled_patterns = zip(compiled, patterns.values())
        # Store a mapping of rules to pairs of compiled search patterns
        # and reponses
        self._map = dict(zip(self.rule, compiled_patterns))

    def __call__(self, bot, trigger):
        pattern = trigger.match.re.pattern
        try:
            chunk_re, response = self._map[pattern]
        except KeyError:
            msg = "SRLinks: Unexpected pattern {0}.".format(repr(pattern))
            print(msg, file=sys.stderr)
            return

        if isinstance(response, tuple):
            response, check = response
        else:
            check = None

        matches = chunk_re.findall(trigger.match.string)
        for match in matches:
            if isinstance(match, tuple):
                match = match[0]
            if not check or check(match):
                quoted = urllib.quote(match)
                formatted = response.format(quoted)
                bot.say(formatted)

srlinks = SRLinks(patterns)
