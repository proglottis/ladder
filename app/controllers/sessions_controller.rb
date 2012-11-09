class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:callback]

  def show
  end

  def create
    @authhash = session[:authhash]
    if params[:commit] =~ /cancel/i
      reset_session
      redirect_to session_path, :notice => "Sign in via #{@authhash[:provider].humanize} cancelled."
    else
      @user = User.new(:name => @authhash[:name], :email => @authhash[:email])
      @service = @user.build_preferred_service(@authhash)
      if @user.save && @service.update_attributes(:user_id => @user.id)
        authenticate_and_redirect(@user, @service)
      else
        redirect_to session_path, :notice => "Unknown account creation error"
      end
    end
  end

  def destroy
    reset_session
    redirect_to root_path, :notice => "Logged out successfully"
  end

  def callback
    omniauth = request.env['omniauth.auth']
    @authhash = {
      :provider => omniauth['provider'],
      :uid => omniauth['uid'],
      :name => omniauth['info']['name'],
      :email => omniauth['info']['email'],
      :first_name => omniauth['info']['first_name'],
      :last_name => omniauth['info']['last_name'],
      :image_url => omniauth['info']['image'],
    }
    session[:authhash] = @authhash
    auth = Service.find_by_provider_and_uid(@authhash[:provider], @authhash[:uid])
    if auth && auth.update_attributes(@authhash)
      authenticate_and_redirect(auth.user, auth)
    else
      render :new
    end
  end

  def failure
    redirect_to session_path, :notice => case params[:message]
    when /invalid_credencials/i
      "Invalid credentials"
    when /timeout/i
      "Authentication timed out"
    else
      "Unknown authentication error"
    end
  end

  private

  def authenticate_and_redirect(user, service)
    redirect = session[:redirect] || root_path
    reset_session
    session[:user_id] = user.id
    session[:service_id] = service.id
    redirect_to redirect, :notice => "Signed in successfully via #{@authhash[:provider].humanize}."
  end
end
