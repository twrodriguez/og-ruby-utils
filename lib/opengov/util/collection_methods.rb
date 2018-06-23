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

  def _matcher(value, predicate, opts = {})
    case predicate
    when Hash
      return false unless value.is_a?(Hash)

      case opts[:collection_match]
      when :all?
        if predicate.empty?
          value.empty?
        else
          _all_block(predicate).call(value)
        end
      when :any?
        _any_block(predicate).call(value)
      else
        raise ArgumentError, 'invalid option for predicate match'
      end
    when Array, Set
      if value.is_a?(Array)
        case opts[:collection_match]
        when :all?
          (predicate & value).size == predicate.size
        when :any?
          (predicate & value).size > 0
        else
          raise ArgumentError, 'invalid option for predicate match'
        end
      else
        predicate.include? value
      end
    when Regexp
      predicate =~ value
    else
      predicate == value
    end
  end
end
