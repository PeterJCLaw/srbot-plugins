
import re

from tests_helpers import path_fudge, FakeBot, FakeTrigger
path_fudge()

from srlinks import patterns, SRLinks, to_search

def test_no_checks():
    def remove_check(val):
        if isinstance(val, tuple):
            return val[0]
        else:
            return val
    values = map(remove_check, patterns.values())
    keys = patterns.keys()
    patterns2 = dict(zip(keys, values))

    srl = SRLinks(patterns2)

    def check_inner(text, expected):
        bot = FakeBot()
        for pattern in keys:
            wrapped = to_search(pattern)
            match = re.match(wrapped, text)
            if match:
                srl(bot, FakeTrigger(match))

        actual = bot.messages
        assert actual == expected, "Wrong output for '{0}'.".format(text)

    def check(expected):
        return lambda text: check_inner(text, expected)

    ## Trac related things ##

    for prefix in ["#", "t:#"]:
        for tpl in ["{prefix}123",
                    "things {prefix}123",
                    "{prefix}123 here",
                    "things {prefix}123 here",
                   ]:
            text = tpl.format(prefix = prefix)
            yield check(['http://trac.srobo.org/ticket/123']), text

    for text in ["123",
                 "things not 123 here",
                 "things not #0147here either",
                 "things not #here either",
                 "#here",
                ]:
        yield check([]), text

    yield check(['http://trac.srobo.org/ticket/123', \
                 'http://trac.srobo.org/ticket/456']), "#123 #456"

    ## Gerrit related things ##

    for prefix in ["gerrit:", "g:"]:
        for tpl in ["{prefix}123",
                    "things {prefix}123",
                    "{prefix}123 here",
                    "things {prefix}123 here",
                    "punctuation1: {prefix}123: here",
                    "punctuation2. {prefix}123. here",
                    "punctuation3, {prefix}123, here",
                    "punctuation4? {prefix}123? here",
                   ]:
            text = tpl.format(prefix = prefix)
            yield check(["http://gerrit.srobo.org/123"]), text

    for prefix in ["gerrit:", "g:"]:
      for tpl in  ["123",
                   "things not 123 here",
                   "things not {prefix}0147here either",
                   "things not {prefix}here either",
                  ]:
            text = tpl.format(prefix = prefix)
            yield check([]), text

    ## CGit related things ##

    for prefix in ["cgit:", "git:"]:
      for name in ["repo-name", "repo/name"]:
          for tpl in ["{prefix}{name}",
                      "things {prefix}{name}",
                      "{prefix}{name} here",
                      "things {prefix}{name} here",
                      "{prefix}{name}.git",
                      "things {prefix}{name}.git",
                      "{prefix}{name}.git here",
                      "things {prefix}{name}.git here",
                     ]:
                text = tpl.format(prefix = prefix, name = name)
                expected = "http://srobo.org/cgit/{name}.git".format(name = name)
                yield check([expected]), text

    for text in ["repo-name.git",
                 "nope git:// things",
                 "things not repo-name.git here",
                ]:
        yield check([]), text
