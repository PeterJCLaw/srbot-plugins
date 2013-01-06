A collection of [rbot](http://ruby-rbot.org) plugins useful to
[Student Robotics](https://www.studentrobotics.org).

The `./test` and `./try` scripts allow for basic testing of the plugins,
without needing an rbot instance, by using the `test_mocks.rb` alternatives.
This is not intended as a full test suite, nor a replacement for actual
checking using rbot, but instead as a fast feedback mechanism when developing.

The `./test` script contains some basic checks for some of the plugins.

The `./try` script can be used to see the behaviour of plugins that
respond to their command without needing arguments, and which conform to
the naming scheme it expects. Run without arguments for help.

Hint: use 'rbot: rescan' to reload the available plugins without
needing to restart your rbot instance.
