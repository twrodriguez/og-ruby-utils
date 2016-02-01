class ThreadPool
  CONCURRENCY_LIMIT = (Settings['concurrency_limit'] || Float::INFINITY).to_f

  def self.parallel(items, opts = {})
    fail 'No block provided' unless block_given?
    opts.reverse_merge!(timeout: 5, concurrency_limit: ThreadPool::CONCURRENCY_LIMIT)

    thread_returns = {}
    pool = new(opts[:concurrency_limit])
    items.each do |item|
      pool.push do
        begin
          Timeout.timeout(opts[:timeout]) do
            thread_returns[item.id] = yield(item)
          end
        rescue Timeout::Error => e
          thread_returns[item.id] = e
        end
      end
    end
    pool.join
    thread_returns
  end

  def initialize(concurrency_limit = ThreadPool::CONCURRENCY_LIMIT)
    @pool = []
    @concurrency_limit = concurrency_limit
  end

  def push(*args, &block)
    fail 'No block provided' unless block_given?
    if @concurrency_limit == 1
      yield(*args)
    else
      @pool << Thread.new(*args, &block)
      join if @pool.size >= @concurrency_limit
    end
  end

  def each(&block)
    @pool.each(&block)
  end

  def join
    @pool.each(&:join)
    @pool.clear
  end
end
