
import re

from tests_helpers import path_fudge, FakeBot, FakeTrigger
path_fudge()

from srlinks import SRLinks

def test_rules():
    rules = {'a': ('{0}',)}
    srl = SRLinks(rules)

    expected = ['a']
    actual = srl.rule
    assert actual == expected, "Wrong rules returned"

def test_unexpected_match():
    rules = {'a': ('{0}',)}
    srl = SRLinks(rules)

    match = re.match('b', 'b')
    trigger = FakeTrigger(match)
    bot = FakeBot()

    srl(bot, trigger)

    assert not bot.messages, "Should be no output"

def helper(pattern, val, text, expected):
    rules = {pattern: val}
    srl = SRLinks(rules)

    match = re.match(pattern, text)
    trigger = FakeTrigger(match)
    bot = FakeBot()

    srl(bot, trigger)

    actual = bot.messages
    assert actual == expected, "Wrong output"

def test_match_no_check():
    helper('a(.*)', '{0}', 'abc', ['bc'])

def test_match_groups():
    helper('a(\d+)', '{0}', 'a1c', ['1'])
    helper('a((\d+)(\w+))', '{0}', 'a1c', ['1c'])

def test_match_check_pass():
    args = []
    def check(x):
        args.append(x)
        return True
    val = ('{0}', check)
    expected = ['bc']
    helper('a(.*)', val, 'abc', expected)

    assert args == expected, "Wrong args passed to check function"

def test_match_check_fail():
    args = []
    def check(x):
        args.append(x)
        return False
    val = ('{0}', check)
    helper('a(.*)', val, 'abc', [])

    assert args == ['bc'], "Wrong args passed to check function"
