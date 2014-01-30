class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate, if: ->{ Rails.env.production? }

  protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['HTTP_AUTH_USERNAME'] && password == ENV['HTTP_AUTH_PASSWORD']
    end
  end
end
