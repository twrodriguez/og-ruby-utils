require_relative 'lazy_collection_enumerator'

class OpenGov::Util::Collection
  include ::Enumerable
  include OpenGov::Util::CollectionMethods

  def initialize(array_like = [])
    @enumerable = array_like
  end

  def each(&block)
    @enumerable.each(&block)
  end

  def lazy
    OpenGov::Util::LazyCollectionEnumerator.new(self, self.size) do |yielder, value|
      yielder << value
    end
  end

  def pluck(*args)
    ret = dup
    ret.pluck!(*args)
    ret
  end

  def where(conditions = {})
    ret = dup
    ret.where!(conditions)
    ret
  end

  def where_not(conditions = {})
    ret = dup
    ret.where_not!(conditions)
    ret
  end

  def pluck!(*args)
    map!(&_pluck_block(args))
  end

  def where!(conditions = {})
    select!(&_all_block(conditions))
  end

  def where_not!(conditions = {})
    reject!(&_any_block(conditions))
  end

  def respond_to?(method_name)
    super || @enumerable.respond_to?(method_name)
  end

  def method_missing(method_name, *args, &block)
    @enumerable.send(method_name, *args, &block)
  end
end
