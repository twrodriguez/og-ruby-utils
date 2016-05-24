require 'set'

module OpenGov::Util::CollectionMethods
  private

  def _pluck_block(args)
    lambda do |item|
      if args.one?
        item[args[0]]
      else
        args.map { |arg| item[arg] }
      end
    end
  end

  def _pluck_slice_block(args)
    lambda do |item|
      args.each_with_object({}) { |arg, memo| memo[arg] = item[arg] }
    end
  end

  def _all_block(conditions)
    lambda do |item|
      conditions.all? do |field, predicate|
        # collection_match will be used by the _matcher method for deep matching
        _matcher(item[field], predicate, collection_match: :all?)
      end
    end
  end

  def _any_block(conditions)
    lambda do |item|
      conditions.any? do |field, predicate|
        # collection_match will be used by the _matcher method for deep matching
        _matcher(item[field], predicate, collection_match: :any?)
      end
    end
  end

  def _matcher(value, predicate, _opts = {})
    case predicate
    when Hash
      # TODO: Implement deep-match logic
    when Array, Set
      predicate.include? value
    when Regexp
      predicate =~ value
    else
      predicate == value
    end
  end
end
