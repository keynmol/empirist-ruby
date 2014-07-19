require 'test/unit'
require 'empirist'
require 'fakefs'
require 'csv'

class TestExperiment < Empirist::Experiment
  def configure
    add_parameter("weights", [5,5])
    add_parameter("mutation_rate", 0.1)


    data_stream(["Error", "PopulationSize"])
  end

  def pre_experiment
  end

  def experiment
    observation(["functional",:triple_sine, 0.04])
  end

  def post_experiment 
  end

end

class EmpiristTest < Test::Unit::TestCase
  def test_init
    trial=TestExperiment.new("asdasd").execute

    assert File.exist?("#{trial.trial_name}-default.csv")

    ::CSV.foreach("#{trial.trial_name}-default.csv") do |row|
        # TODO: fix the tests
      end

  end

 
end