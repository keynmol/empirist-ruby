require 'optparse'
require 'ostruct'
require 'ruby-progressbar'

module Empirist
	class Experiment

		attr_reader :trial_name, :trial_id, :parameters

		def initialize(description="", opts={})
			agent_string=(opts[:agent] || "localhost:5050").split(":")

			agent_host, agent_port=agent_string

			@agent=Agent.new(agent_host, agent_port)

			@experiment_name=self.class
			@streams={}
			@project="Mess"
			@report=Report.new()
			@trial_name=nil
			@parser=OptionParser.new
			@parameters={}
			@add_run=true
			@runs=1
			@data_folder=@agent.local_cache_folder
			@stages=0
			@stage=1

			@parser.banner="Usage: #{@experiment_name}.rb ...arguments..."

			configure
			parse_command_line
			configure_report
		end

		def project_name new_name
			@project=new_name
		end

		def configure_report
			@report.add_writer(@report.create_csv_writer("#{@data_folder}/#{trial_name}-%{stream}.csv"))
		end

		def parse_command_line  
			if @add_run
				@parameters[:runs]=@runs
				@report.add_parameter(:Run,0)
				@parser.on("--runs VALUE", Integer) do |value|
					@parameters[:runs]=value 
				end
			end

			@parser.parse!
			@parameters=OpenStruct.new(@parameters)
		end

		def convert_class(old)
			old==Fixnum ? Integer : old
		end


		

		def add_parameter(name, default=nil)
			@parameters[name.to_sym]=default
			cls=default.nil? ? Integer : convert_class(default.class)
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

			@parser.on("--#{name} #{param_template}", cls) do |value|
				@parameters[name.to_sym]=value
			end
		end

		def trial_name
			unless @trial_name
				options=Hash[@parameters.marshal_dump.map{|k,v| [k, v.to_s]}]
				options['__timestamp']=Time.now
				options['__project']=@project
				options['__experiment']=@experiment_name.to_s
				options['__success']=0

				# @trial_id=trials.insert(options)
				# @trial_name=@project+"-"+@experiment_name.to_s+"-"+@trial_id.to_s

				@trial_id=@agent.create_trial(options)
				@trial_name=@trial_id.to_s
			end

			@trial_name
		end




		def execute
			@progress=0
			p=ProgressBar.create( :format  => '%a %b>%i %p%% %t',
                    :progress_mark  => ' ',
                    :remainder_mark => '.',
                    :total => parameters.runs)
			@agent.update_progress(0.0)
			parameters.runs.times do |run_number|
				@report.change_state(:Run, run_number) if @add_run
				@current_run=run_number
				
				pre_experiment
				experiment
				post_experiment
				
				p.increment

				@agent.update_progress(100*(p.progress.to_f/p.total))
			end

			@report.finish

			@agent.set_success
			@agent.upload_data @report.streams_names


			self
		end

		def pre_experiment
		end

		def post_experiment
		end

		def experiment
		end

		def add_state(name, value)
			@report.add_parameter(name, value)
		end

		def get_state(name)
			@report.parameters[name]
		end
		
		def data_stream(scheme, name="default", parameters={})
			@report.add_stream(name, DataStream.new(scheme, parameters))
		end

		def observation(data, stream="default")
			@report.observation(stream, data)
		end
	end
end