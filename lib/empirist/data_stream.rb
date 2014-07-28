module Empirist
	class DataStream
		attr_reader :scheme, :melted

		def initialize(scheme, parameters={})
			@scheme=scheme
			@melted=parameters[:melt]||[]
		end

		def observation

		end

		def melt(param_name)
			@melted<<param_name
		end

		def melted?(param_name)
			@melted.include? param_name
		end
	end
end