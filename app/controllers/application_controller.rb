class ApplicationController < ActionController::Base
  helper TitleHelper

  protect_from_forgery

  rescue_from CanCan::AccessDenied do |ex|
    redirect_back :alert => ex.message
  end

  protected
  def redirect_back(*args)
    target = root_url
    if request.env["HTTP_REFERER"].try {|s| s.start_with? root_url}
      # user came from our site
      target = :back
    end
    redirect_to target, *args
  end
end
