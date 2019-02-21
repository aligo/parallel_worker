require "./spec_helper"

describe ParallelWorker do

  describe ParallelWorker::Fiber do

    it "#perform_all works" do
      worker = ParallelWorker::Fiber(Int32, String).new(4) do |input_int|
        input_int.to_s
      end
      results = worker.perform_all (0..256).to_a

      results.should eq((0..256).to_a.map(&.to_s))
    end

  end

  describe ParallelWorker::Fiber do

    it "#perform_all works" do
      worker = ParallelWorker::Process(Int32, String).new(4) do |input_int|
        input_int.to_s
      end
      results = worker.perform_all (0..256).to_a

      results.should eq((0..256).to_a.map(&.to_s))
    end

  end
  
end
