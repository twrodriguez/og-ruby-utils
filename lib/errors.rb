module Errors
  # Standard Errors
  module HttpStatusError
    attr_reader :code

    def name
      to_s.split('::').last.underscore
    end

    def status
      name.to_sym
    end

    def titlecase
      name.titlecase
    end

    def render_json
      [json: { error: code, message: titlecase }, status: code]
    end

    def render
      ["exceptions/#{name}", { status: status, layout: 'exception' }]
    end
  end

  class NotFound < StandardError
    extend HttpStatusError
    @code = 404
  end

  class BadRequest < StandardError
    extend HttpStatusError
    @code = 400
  end

  class Forbidden < StandardError
    extend HttpStatusError
    @code = 403
  end

  class ServiceUnavailable < StandardError
    extend HttpStatusError
    @code = 503
  end
end
