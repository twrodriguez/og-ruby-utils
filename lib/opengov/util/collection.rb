require_relative 'lazy_collection_enumerator'
require_relative 'thread_pool'

class OpenGov::Util::Collection
  include ::Enumerable
  include ::Comparable
  include OpenGov::Util::CollectionMethods

  def initialize(enum = [])
    unless enum.is_a?(::Enumerable) && enum.respond_to?(:dup)
      fail TypeError, 'Argument must be a dup-able enumerable object'
    end

    @enumerable = enum
  end

  def <=>(other)
    case other
    when OpenGov::Util::Collection
      @enumerable <=> other.instance_variable_get('@enumerable')
    else
      @enumerable <=> other
    end
  end

  def dup
    super.tap { |c| c.instance_variable_set('@enumerable', @enumerable.dup) }
  end

  def each(&block)
    @enumerable.each(&block)
  end

  def lazy
    OpenGov::Util::LazyCollectionEnumerator.new(self, size) do |yielder, value|
      yielder << value
    end
  end

  def index_by(*dig_args, &block)
    fail ArgumentError, 'Must provide exactly one argument or a block' if !dig_args.empty? && block_given?
    block = ->(obj) { obj.dig(*dig_args) rescue nil } unless dig_args.empty?

    each_with_object(OpenGov::Util::LookupHash.new) do |item, memo|
      memo[block.call(item)] = item
    end
  end

  def rfind(&block)
    return unless respond_to?(:rindex, true)
    idx = rindex(&block)
    idx && at(idx)
  end

  def pluck!(*args)
    map!(&_pluck_block(args))
  end

  def pluck_slice!(*args)
    map!(&_pluck_slice_block(args))
  end

  def where!(conditions = {})
    select!(&_all_block(conditions))
  end

  def where_not!(conditions = {})
    reject!(&_any_block(conditions))
  end

  def pluck(*args)
    dup.tap { |c| c.pluck!(*args) }
  end

  def pluck_slice(*args)
    dup.tap { |c| c.pluck_slice!(*args) }
  end

  def where(conditions = {})
    dup.tap { |c| c.where!(conditions) }
  end

  def where_not(conditions = {})
    dup.tap { |c| c.where_not!(conditions) }
  end

  def find_by(conditions = {})
    find(&_all_block(conditions))
  end

  def parallel_map(parallel_opts = {}, &block)
    OpenGov::Util::ThreadPool.parallel_map(self, parallel_opts, &block)
  end
  alias_method :pmap, :parallel_map

  def respond_to?(method_name, *args)
    super || @enumerable.respond_to?(method_name, *args)
  end

  def method_missing(method_name, *args, &block)
    @enumerable.send(method_name, *args, &block)
  end
end
