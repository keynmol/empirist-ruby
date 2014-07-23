module Empirist
	module Writers
		class ReportWriter
			
			def addStream(stream, name)
			end
			
			def finish
			end
		end

		class CSVWriter < ReportWriter
			def initialize(template)
				@template=template
				@open_files={}
			end

			def record(stream, data)
				data_line=data.map{|d| d[1]}.join(";")
				open_file(stream) unless @open_files.has_key?(stream)
				
				unless @open_files[stream][:header_written?]
					header_line=data.map{|d| d[0]}.join(";")
					@open_files[stream][:file].write(header_line+"\n")
					@open_files[stream][:header_written?]=true
				end
				
				@open_files[stream][:file].write(data_line+"\n")
			end

			def open_file(stream)
				@open_files[stream]={:file => File.open(@template % {stream: stream},"w"), :header_written? => false}
			end

			def finish
				@open_files.map {|_,v| v[:file].close}
			end
		end
	end
end