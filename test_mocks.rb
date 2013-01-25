# A mock of the rbot Plugin base
class Plugin
	def map(a)
	end
	def register(a)
	end
end

class PrivMessage
	attr_accessor :message

	def reply(thing)
	end
end

class PrintingMessage < PrivMessage
	def reply(thing)
		print thing, "\n"
	end
end

class TestableMessage < PrivMessage
	def initialize
		@replies = ""
	end

	def get_replies
		return @replies
	end

	def reply(thing)
		@replies += thing + "\n"
	end
end
