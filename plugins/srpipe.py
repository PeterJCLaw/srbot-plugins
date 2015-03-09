
from __future__ import print_function

import os
import stat
import sys
import threading

def get_fifo(path):
    if not os.path.exists(path):
        # Create the pipe, ensure everyone can write to it
        os.umask(0155)
        os.mkfifo(path)

    if not stat.S_ISFIFO(os.stat(path).st_mode):
        not_fifo_warning = "Warning: PIPE_PATH '{0}' doesn't look like a FIFO".format(path)
        print(not_fifo_warning, file=sys.stderr)

    fifofd = os.open(path, os.O_RDONLY | os.O_NONBLOCK)
    try:
        return os.fdopen(fifofd, 'r')
    except:
        # Handle exceptions from the conversion and close the handle.
        # _Only_ close the handle in this case since otherwise the
        # caller wouldn't be able to use the file they called us to get.
        os.close(fifofd)
        raise

def make_thread(pipe_path, recipient, bot):
    exit_signal = threading.Event()

    def job():
        with get_fifo(pipe_path) as fifo:
            # Loop until the exit signal is set,
            # check the fifo every 0.2s
            while not exit_signal.wait(0.2):
                # NB: `for line in fifo` doesn't work,
                # presumably because it's a pipe not a file
                for line in fifo.readlines():
                    line = line.strip()
                    bot.msg(recipient, line)

    thread_name = "Pipe from '{0}' to '{1}'".format(pipe_path, recipient)
    thread = threading.Thread(name = thread_name, target = job)
    return thread, exit_signal

def setup(willie):
    memory = willie.memory['srpipe'] = []

    try:
        config = willie.config.srpipe
        channel = config.channel
        pipe_path = config.pipe_path
    except Exception as e:
        print("Failed to get configuration data for srpipe: {0}".format(e), file=sys.stderr)
        return

    thread_etc = make_thread(pipe_path, channel, willie)
    memory.append(thread_etc)
    thread_etc[0].start()

def shutdown(willie):
    memory = willie.memory['srpipe']
    for thread, exit_signal in memory:
        exit_signal.set()

    for thread, exit_signal in memory:
        print("Waiting for {0}.".format(thread.name), file=sys.stderr)
        thread.join()

    print("All srpipes closed.", file=sys.stderr)

if __name__ == '__main__':
    class FakeBot:
        def msg(self, to, content):
            print("Message for '{to}': {msg}".format(to=to, msg=content))

    thread, exit_signal = make_thread('/tmp/hash-srobo', '#srobo-bots', FakeBot())
    thread.start()

    try:
        while thread.is_alive():
            thread.join(0.5)
        print("Thread quit early!")
    except:
        exit_signal.set()
        thread.join()
