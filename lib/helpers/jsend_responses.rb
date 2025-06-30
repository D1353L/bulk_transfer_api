# frozen_string_literal: true

module Helpers
  module JsendResponses
    def respond_with_unprocessable_entity!(message:)
      render json: { status: 'fail',
                     message: 'Unprocessable Entity',
                     data: { exception: message, response_code: 422 } },
             status: :unprocessable_entity
    end

    def respond_with_internal_server_error!(message:)
      render json: { status: 'error',
                     message: 'Something went wrong',
                     data: { exception: display_exception(exception_message: message), response_code: 500 } },
             status: :internal_server_error
    end

    def respond_with_not_found!(message:)
      render json: { status: 'fail',
                     message:, data: { response_code: 404 } },
             status: :not_found
    end

    def respond_with_locked!(message:)
      render json: { status: 'fail',
                     message:,
                     data: { response_code: 423 } },
             status: :locked
    end

    def display_exception(exception_message:, default_message: 'Failed')
      Rails.application.config.respond_with_detailed_exceptions ? exception_message : default_message
    end
  end
end
