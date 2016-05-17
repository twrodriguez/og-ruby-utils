require_relative 'collection_methods'

class OpenGov::Util::LazyCollectionEnumerator < ::Enumerator::Lazy
  include OpenGov::Util::CollectionMethods

  def method_missing?(*args)
    force.send(*args)
  end

  def pluck(*args)
    self.class.new(self) do |yielder, value|
      yielder << _pluck_block(args).call(value)
    end
  end

  def pluck_to_h(*args)
    self.class.new(self) do |yielder, value|
      yielder << _pluck_to_h_block(args).call(value)
    end
  end

  def where(conditions = {})
    self.class.new(self) do |yielder, value|
      should_include = _all_block(conditions).call(value)
      yielder << value if should_include
    end
  end

  def where_not(conditions = {})
    self.class.new(self) do |yielder, value|
      should_reject = _any_block(conditions).call(value)
      yielder << value unless should_reject
    end
  end
end
