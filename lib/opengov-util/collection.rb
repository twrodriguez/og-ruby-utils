require_relative 'lazy_collection_enumerator'

class OpenGov::Util::Collection
  include ::Enumerable
  include OpenGov::Util::CollectionMethods

  def initialize(enum = [])
    unless enum.is_a?(::Enumerable) && enum.respond_to?(:dup)
      fail TypeError, 'Argument must be a dup-able enumerable object'
    end

    @enumerable = enum
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

  def pluck!(*args)
    map!(&_pluck_block(args))
  end

  def pluck_to_h!(*args)
    map!(&_pluck_to_h_block(args))
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

  def pluck_to_h(*args)
    dup.tap { |c| c.pluck_to_h!(*args) }
  end

  def where(conditions = {})
    dup.tap { |c| c.where!(conditions) }
  end

  def where_not(conditions = {})
    dup.tap { |c| c.where_not!(conditions) }
  end

  def respond_to?(method_name)
    super || @enumerable.respond_to?(method_name)
  end

  def method_missing(method_name, *args, &block)
    @enumerable.send(method_name, *args, &block)
  end
end
