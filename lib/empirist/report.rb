module Empirist
	class Report
		attr_accessor :parameters
		

		def initialize
			@streams={}
			@writers=[]
			@parameters={}
		end


		def finish
			@writers.map &:finish
		end

		def add_writer(writer)
			@writers<<writer
		end

		def streams_names
			@streams.keys
		end

		def observation(stream, data)
			flat=[]
			hash={}

			scheme=@streams[stream].scheme

			@parameters.each_key do |pname|
				flat << [pname, @parameters[pname]]
				hash[pname]=@parameters[pname]
			end

			if data.is_a?(Hash)
				scheme.each do |field|
					if data[field].is_a?(Array)
						data[field].each_with_index do |subvalue, index|
							flat<<["#{field}#{index}".to_sym, subvalue]
							hash["#{field}#{index}".to_sym]=subvalue
						end
					end
				end
			end

			if data.is_a?(Array)
				scheme.each_with_index do |field, index|
					datum=data[index].is_a?(Array) ? data[index] : [data[index]]
					indexes=(0..datum.length).to_a.map(&:to_s)
					indexes[0]=""
					datum.zip(indexes).each {|value, index|
						flat <<["#{field}#{index}".to_sym, value]
						hash["#{field}#{index}".to_sym]=value
					}

				end
			end

			@writers.each {|writer|
				writer.record stream, flat
			}
		end

		def add_stream(name, stream)
			@streams[name]=stream
		end

		def create_csv_writer(template)
			Writers::CSVWriter.new(template)
		end

		def add_parameter(name, value)
			@parameters[name.to_sym]=value
		end
	end
end