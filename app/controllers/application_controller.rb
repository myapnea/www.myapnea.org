class ApplicationController < ActionController::Base

  # Add flash types
  add_flash_types :warning

  # Layout
  layout 'layouts/application'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :store_location

  def store_location
    if (params[:controller].in?(['forums', 'topics', 'posts']) &&
        !request.fullpath.match("#{request.script_name}/login") &&
        !request.fullpath.match("#{request.script_name}/join") &&
        !request.fullpath.match("#{request.script_name}/password") &&
        !request.fullpath.match("#{request.script_name}/sign_out") &&
        !request.xhr?) # don't store ajax calls
      store_location_in_session
    end
  end

  # Send 'em back where they came from with a slap on the wrist
  def authority_forbidden(error)
    Authority.logger.warn(error.message)

    if error.action == 'research'
      session[:return_to] = request.fullpath
      redirect_to consent_path, alert: "In order to participate in research, read and accept the consent and privacy policy."
    elsif error.resource.to_s == "ResearchTopic" and error.action == 'create'
      session[:return_to] = request.fullpath
      redirect_to social_profile_path, alert: "In order to create your own research questions, please create a social profile below."
    else
      redirect_to request.referrer.presence || root_path, :alert => "Sorry! You attempted to visit a page you do not have access to. If you believe this message to be unjustified, please contact us at [support@myapnea.org]."
    end
  end

  def set_active_top_nav_link_to_home
    @active_top_nav_link = :home
  end

  def set_active_top_nav_link_to_forums
    @active_top_nav_link = :forums
  end

  def set_active_top_nav_link_to_surveys
    @active_top_nav_link = :surveys
  end

  def set_active_top_nav_link_to_research
    @active_top_nav_link = :research
  end

  def set_active_top_nav_link_to_learn
    @active_top_nav_link = :learn
  end

  def no_layout
    render layout: false
  end

  def authenticate_research
    session[:return_to] = request.fullpath
    # raise Authority::SecurityViolation.new(current_user, 'research', action_name) unless current_user.ready_for_research?
    if current_user.ready_for_research?
      return
    else
      if current_user.provider? or current_user.is_only_academic?
        redirect_to terms_of_access_path
      else
        redirect_to consent_path
      end
    end
  end

  def empty_response_or_root_path(path = root_path)
    respond_to do |format|
      format.html { redirect_to path }
      format.js { render nothing: true }
      format.json { head :no_content }
      format.text { render nothing: true }
    end
  end

  def check_owner_or_moderator
    redirect_to root_path, alert: "You do not have sufficient privileges to access that page." unless current_user.owner? or current_user.moderator?
  end

  def check_owner
    redirect_to root_path, alert: "You do not have sufficient privileges to access that page." unless current_user.owner?
  end

  def check_moderator
    redirect_to root_path, alert: "You do not have sufficient privileges to access that page." unless current_user.moderator?
  end


  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  protected

  def store_location_in_session
    session[:previous_url] = request.fullpath
  end

end
