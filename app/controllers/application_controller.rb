class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller
  include Findingaids::Catman
  
  helper_method :repositories
  
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 
  
  protect_from_forgery
  layout Proc.new{ |controller| (controller.request.xhr?) ? false : "application" }

  # Adds authentication actions in application controller
  require 'authpds'
  include Authpds::Controllers::AuthpdsController
  
  # Imitate logged in user
  def current_user_dev
    @current_user ||= User.find_by_username("global_admin")
  end
  alias_method :current_user, :current_user_dev if Rails.env == 'development'
  
  ##
  # Alias class method from catalog controller, gotta be a better way hmm?
  def repositories
    CatalogController::repositories
  end
  helper_method :repositories
  
end
