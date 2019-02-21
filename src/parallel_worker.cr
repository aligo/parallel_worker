# TODO: Write documentation for `ParallelWorker`

require "msgpack"
module ParallelWorker
  VERSION = "0.0.1"

  class FiberWorker(T, R)
    def initialize(&block : (T) -> R)
      @job_ch = Channel(T).new
      @ret_ch = Channel(R).new
      spawn do
        while job = @job_ch.receive
          @ret_ch.send block.call(job)
        end
      end
    end

    def perform(job : T)
      @job_ch.send job
      @ret_ch.receive
    end

    def exit
    end
  end

  class ProcessWorker(T, R)
    def initialize(&block : (T) -> R)
      @job_reader, @job_writer = IO.pipe
      @ret_reader, @ret_writer = IO.pipe
      @process = ::Process.fork do
        loop do
          job = T.from_msgpack(@job_reader)
          @ret_writer.write(block.call(job).to_msgpack)
        end
      end
    end

    def perform(job : T)
      @job_writer.write(job.to_msgpack)
      ret = R.from_msgpack(@ret_reader)
    end

    def exit
      @process.kill
    end
  end

  class Base(X, T, R)
    def initialize(num_workers : Int32, &block : (T) -> R)
      @workers_ch = Channel(X).new(num_workers)
      @workers = Array(X).new(num_workers)
      num_workers.times.each do
        worker = X.new(&block)
        @workers_ch.send(worker)
        @workers.push(worker)
      end
    end

    def perform(job : T)
      ret_ch = Channel(R).new
      worker = @workers_ch.receive
      spawn do
        ret = worker.perform(job)
        @workers_ch.send(worker)
        ret_ch.send(ret)
      end
      ret_ch
    end

    def perform_all(jobs : Array(T))
      ret = jobs.map {|job| self.perform(job) }.map(&.receive)
      @workers.each(&.exit)
      ret
    end

  end


  class Fiber(T, R) < Base(FiberWorker(T, R), T, R)
  end

  class Process(T, R) < Base(ProcessWorker(T, R), T, R)
  end
end
