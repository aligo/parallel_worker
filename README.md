# parallel_worker

Run a processing block in parallel fibers/processes.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     parallel_worker:
       github: aligo/parallel_worker
   ```

2. Run `shards install`

## Usage

```crystal
require "parallel_worker"

# Pass all 0..256 one by one to block, running in 4 fiber workers, then resulting a Array(String) as return

worker = ParallelWorker::Fiber(Int32, String).new(4) do |input_int|
  input_int.to_s
end
results = worker.perform_all (0..256).to_a 

# Or run the block in 2 processes

worker = ParallelWorker::Process(Int32, String).new(2) do |input_int|
  input_int.to_s
end
results = worker.perform_all (0..256).to_a

```

## Contributing

1. Fork it (<https://github.com/aligo/parallel_worker/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [aligo Kang](https://github.com/aligo)
