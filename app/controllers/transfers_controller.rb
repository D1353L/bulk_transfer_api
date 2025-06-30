# frozen_string_literal: true

class TransfersController < ApplicationController
  def bulk_create
    validate_params!(schema: Schemas::BulkTransferCreate, params: strong_params)

    BulkTransferService.new(
      sender_bic: strong_params[:organization_bic],
      sender_iban: strong_params[:organization_iban],
      credit_transfers: strong_params[:credit_transfers],
      idempotency_key: request.headers['Idempotency-Key']
    ).perform!

    head :no_content
  end

  private

  def strong_params
    params.require(:transfer).permit(:organization_bic, :organization_iban,
                                     credit_transfers: %i[amount currency counterparty_name
                                                          counterparty_bic counterparty_iban description]).to_h
  end
end
