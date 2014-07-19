require 'mongo'
require 'optparse'
require 'ostruct'

module Empirist
	class Experiment

		attr_reader :trial_name, :trial_id

		@@client=::Mongo::MongoClient.new("localhost")
		@@db=@@client.db("empirist")
		@@trials=@@db["trials"]



		def initialize(description="")
			@experiment_name=self.class
			@streams={}
			@namespace="Mess"
			@report=Report.new()
			@trial_name=nil
			@parser=OptionParser.new
			@parameters={}
			@add_run=true
			@runs=1
			@data_folder="."

			@parser.banner="Usage: #{@experiment_name}.rb ...arguments..."

			configure
			parse_command_line
			configure_report
		end

		def configure_report
			@report.add_writer(@report.create_csv_writer("#{trial_name}-%{stream}.csv"))
		end

		def parse_command_line
			if @add_run
				@parameters[:Runs]=@runs
				@report.add_parameter(:Run,0)
				@parser.on("--runs VALUE", Integer) do |value|
					@parameters[:Runs]=value
				end
			end

			@parser.parse!
			@parameters=OpenStruct.new(@parameters)
		end

		

		def add_parameter(name, default=nil)
			@parameters[name.to_sym]=default
			cls=default.nil? ? Integer : default.class
			if cls==Array
				if default.length > 0
					el_cls=default[0].class
				else
					el_cls=Integer
				end
				param_template="x,y,z"
			else
				param_template="value"
			end

			@parser.on("--#{name} #{param_template}", default.nil? ? Integer : default.class) do |value|
				@parameters[name.to_sym]=value
			end
		end

		def trials
			@@trials
		end

		def set_success
			trials.find(:__id => @trial_id)
		end

		def trial_name
			unless @trial_name
				options=@parameters.marshal_dump
				options['__timestamp']=Time.now
				options['__namespace']=@namespace
				options['__experiment']=@experiment_name.to_s
				options['__success']=0

				@trial_id=trials.insert(options)
				@trial_name=@namespace+"-"+@experiment_name.to_s+"-"+@trial_id.to_s
			end

			@trial_name
		end

		def execute
			@runs.times do |run_number|
				pre_experiment
				experiment
				post_experiment
			end

			@report.finish

			self
		end

		def add_state(name, value)
			@report.add_parameter(name, value)
		end
		
		def data_stream(scheme, name="default")
			@report.add_stream(name, DataStream.new(scheme))
		end

		def observation(data, stream="default")
			@report.observation(stream, data)
		end
	end
end