class CryptoController < ApplicationController
  def public_certificate
    render plain: File.read("/foundation/crypto/foundation.public.certificate")
  end
end
