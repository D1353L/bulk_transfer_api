# frozen_string_literal: true

class ApplicationController < ActionController::API
  class InvalidParamsError < StandardError; end

  include Helpers::JsendResponses

  rescue_from StandardError, with: :handle_exception

  private

  def validate_params!(schema:, params:)
    result = schema.call(params)

    raise InvalidParamsError, result.errors.to_h unless result.success?
  end

  def handle_exception(exception)
    log_exception(exception)

    case exception
    when BulkTransferService::BankAccountNotFound
      respond_with_not_found!(message: exception.message)
    when ActiveRecord::RecordInvalid, BulkTransferService::InsufficientFunds, InvalidParamsError
      respond_with_unprocessable_entity!(message: exception.message)
    when BulkTransferService::BankAccountLocked
      respond_with_locked!(message: exception.message)
    else
      respond_with_internal_server_error!(message: exception.message)
    end
  end

  def log_exception(exception)
    Rails.logger.error("Error: #{format_exception_string(exception)}")
  end

  def format_exception_string(exception)
    "#{exception.message}\n#{exception.backtrace.join("\n")}"
  end
end
