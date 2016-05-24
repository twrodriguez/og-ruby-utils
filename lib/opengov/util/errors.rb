module OpenGov
  module Util
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

      class Continue < ::StandardError
        extend HttpStatusError
        @code = 100
      end

      class SwitchProtocol < ::StandardError
        extend HttpStatusError
        @code = 101
      end

      class OK < ::StandardError
        extend HttpStatusError
        @code = 200
      end

      class Created < ::StandardError
        extend HttpStatusError
        @code = 201
      end

      class Accepted < ::StandardError
        extend HttpStatusError
        @code = 202
      end

      class NonAuthoritativeInformation < ::StandardError
        extend HttpStatusError
        @code = 203
      end

      class NoContent < ::StandardError
        extend HttpStatusError
        @code = 204
      end

      class ResetContent < ::StandardError
        extend HttpStatusError
        @code = 205
      end

      class PartialContent < ::StandardError
        extend HttpStatusError
        @code = 206
      end

      class MultiStatus < ::StandardError
        extend HttpStatusError
        @code = 207
      end

      class MultipleChoices < ::StandardError
        extend HttpStatusError
        @code = 300
      end

      class MovedPermanently < ::StandardError
        extend HttpStatusError
        @code = 301
      end

      class Found < ::StandardError
        extend HttpStatusError
        @code = 302
      end

      class SeeOther < ::StandardError
        extend HttpStatusError
        @code = 303
      end

      class NotModified < ::StandardError
        extend HttpStatusError
        @code = 304
      end

      class UseProxy < ::StandardError
        extend HttpStatusError
        @code = 305
      end

      class TemporaryRedirect < ::StandardError
        extend HttpStatusError
        @code = 307
      end

      class BadRequest < ::StandardError
        extend HttpStatusError
        @code = 400
      end

      class Unauthorized < ::StandardError
        extend HttpStatusError
        @code = 401
      end

      class PaymentRequired < ::StandardError
        extend HttpStatusError
        @code = 402
      end

      class Forbidden < ::StandardError
        extend HttpStatusError
        @code = 403
      end

      class NotFound < ::StandardError
        extend HttpStatusError
        @code = 404
      end

      class MethodNotAllowed < ::StandardError
        extend HttpStatusError
        @code = 405
      end

      class NotAcceptable < ::StandardError
        extend HttpStatusError
        @code = 406
      end

      class ProxyAuthenticationRequired < ::StandardError
        extend HttpStatusError
        @code = 407
      end

      class RequestTimeOut < ::StandardError
        extend HttpStatusError
        @code = 408
      end

      class Conflict < ::StandardError
        extend HttpStatusError
        @code = 409
      end

      class Gone < ::StandardError
        extend HttpStatusError
        @code = 410
      end

      class LengthRequired < ::StandardError
        extend HttpStatusError
        @code = 411
      end

      class PreconditionFailed < ::StandardError
        extend HttpStatusError
        @code = 412
      end

      class RequestEntityTooLarge < ::StandardError
        extend HttpStatusError
        @code = 413
      end

      class RequestURITooLong < ::StandardError
        extend HttpStatusError
        @code = 414
      end

      class UnsupportedMediaType < ::StandardError
        extend HttpStatusError
        @code = 415
      end

      class RequestedRangeNotSatisfiable < ::StandardError
        extend HttpStatusError
        @code = 416
      end

      class ExpectationFailed < ::StandardError
        extend HttpStatusError
        @code = 417
      end

      class UnprocessableEntity < ::StandardError
        extend HttpStatusError
        @code = 422
      end

      class Locked < ::StandardError
        extend HttpStatusError
        @code = 423
      end

      class FailedDependency < ::StandardError
        extend HttpStatusError
        @code = 424
      end

      class UpgradeRequired < ::StandardError
        extend HttpStatusError
        @code = 426
      end

      class PreconditionRequired < ::StandardError
        extend HttpStatusError
        @code = 428
      end

      class TooManyRequests < ::StandardError
        extend HttpStatusError
        @code = 429
      end

      class RequestHeaderFieldsTooLarge < ::StandardError
        extend HttpStatusError
        @code = 431
      end

      class InternalServerError < ::StandardError
        extend HttpStatusError
        @code = 500
      end

      class NotImplemented < ::StandardError
        extend HttpStatusError
        @code = 501
      end

      class BadGateway < ::StandardError
        extend HttpStatusError
        @code = 502
      end

      class ServiceUnavailable < ::StandardError
        extend HttpStatusError
        @code = 503
      end

      class GatewayTimeOut < ::StandardError
        extend HttpStatusError
        @code = 504
      end

      class VersionNotSupported < ::StandardError
        extend HttpStatusError
        @code = 505
      end

      class InsufficientStorage < ::StandardError
        extend HttpStatusError
        @code = 507
      end

      class NetworkAuthenticationRequired < ::StandardError
        extend HttpStatusError
        @code = 511
      end
    end
  end
end
