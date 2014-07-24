require 'json'
require 'faraday'

module Empirist
	class Agent

		attr_reader :local_cache_folder, :trial_id

		def initialize(host, port)
			@agent_connection=::Faraday.new("http://#{host}:#{port}")

			server_address=(@agent_connection.get '/server').body
			@local_cache_folder=(@agent_connection.get '/local_cache').body
			@server_connection=::Faraday.new(server_address) do |f|
								  f.request :multipart
								  f.request :url_encoded
								  f.adapter :net_http # This is what ended up making it work
								end

		end

		def create_trial(params)
			# we create trial directly on server
			resp=@server_connection.post '/create_trial',  JSON.generate(params)
			@trial_id=resp.body
		end

		def upload_data(streams_names)
			raise "Trial hasn't been created yet" if @trial_id.nil?
			
			streams_names.each do |stream|
				datafile=File.join(@local_cache_folder, "#{trial_id}-#{stream}.csv")
				if File.exists?(datafile)
					puts "uploading path: #{datafile}, filesize: #{File.size(datafile)}" 
					params={file: Faraday::UploadIO.new(datafile, 'text/csv'),
							data_stream: stream,
							trial_id: trial_id}

					
					@server_connection.post '/upload_datastream', params
				end
			end
		end

		def set_success
			@server_connection.post '/set_success', {trial_id: trial_id}
		end
	end
end