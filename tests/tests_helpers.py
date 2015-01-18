
import os.path
import sys

def path_fudge():
    mydir = os.path.dirname(os.path.abspath(__file__))
    root = os.path.dirname(mydir)

    sys.path.insert(0, os.path.join(root, 'plugins'))
