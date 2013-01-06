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
		print thing, "\n"
	end
end
