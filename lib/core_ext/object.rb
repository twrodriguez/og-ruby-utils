# frozen_string_literal: true
class Object
  def is_any_of?(*klasses)
    klasses.reduce(false) { |r, klass| r || is_a?(klass) }
  end
end
