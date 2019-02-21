class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def user
    @user ||= User.first.tap { |u| raise "NoAccountError" if u.nil? }
  end
end
