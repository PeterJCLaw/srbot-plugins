
import os.path
import sys

def path_fudge():
    mydir = os.path.dirname(os.path.abspath(__file__))
    root = os.path.dirname(mydir)

    sys.path.insert(0, os.path.join(root, 'plugins'))

class FakeTrigger(object):
    def __init__(self, match):
        self.match = match

    @property
    def group(self):
        return self.match.group

class FakeBot(object):
    def __init__(self):
        self.messages = []

    def say(self, message):
        self.messages.append(message)
