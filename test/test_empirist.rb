require 'test/unit'
require 'empirist'
require 'csv'

class TestExperiment < Empirist::Experiment
  def configure
    add_parameter("weights", [5,5])
    add_parameter("mutation_rate", 0.1)
    add_parameter "epochs", 1000

    @runs=100

    data_stream ["Error", "RealInput", "NoiseInput"], "input_weights", melt: %w{RealInput NoiseInput}

    @data_folder="."
  end 

  def pre_experiment 
  end

  def experiment
    observation ["functional",:triple_sine, 0.04], "input_weights"
  end

  def post_experiment 
  end

end

class EmpiristTest < Test::Unit::TestCase
  def test_init
    trial=TestExperiment.new("asdasd", agent: "localhost:5050").execute
    file="./#{trial.trial_id}-input_weights.csv"
    puts File.read(file)
  end

 
end