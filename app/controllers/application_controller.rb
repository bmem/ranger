class ApplicationController < Bmem::ApplicationController
  helper Bmem::TitleHelper

  protect_from_forgery
end
