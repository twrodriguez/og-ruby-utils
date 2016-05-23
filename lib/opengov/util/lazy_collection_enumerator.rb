require_relative 'collection_methods'

class OpenGov::Util::LazyCollectionEnumerator < ::Enumerator::Lazy
  include OpenGov::Util::CollectionMethods

  def method_missing?(*args)
    force.send(*args)
  end

  def pluck(*args)
    chain do |yielder, value|
      yielder << _pluck_block(args).call(value)
    end
  end

  def pluck_slice(*args)
    chain do |yielder, value|
      yielder << _pluck_slice_block(args).call(value)
    end
  end

  def where(conditions = {})
    chain do |yielder, value|
      should_include = _all_block(conditions).call(value)
      yielder << value if should_include
    end
  end

  def where_not(conditions = {})
    chain do |yielder, value|
      should_reject = _any_block(conditions).call(value)
      yielder << value unless should_reject
    end
  end

  def chain(&block)
    self.class.new(self, &block)
  end
end
