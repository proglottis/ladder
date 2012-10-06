class SessionsController < ApplicationController
  def show
  end

  def create
    @authhash = session[:authhash]
    if params[:commit] =~ /cancel/i
      reset_session
      redirect_to session_path, :notice => "Sign in via #{@authhash[:provider].capitalize} canceled."
    else
      @user = User.new(:name => @authhash[:name], :email => @authhash[:email])
      @user.services.build(@authhash)
      if @user.save
        reset_session
        session[:user_id] = @user.id
        session[:service_id] = @user.services.last.id
        redirect_to root_path, :notice => "Signed in successfully via #{@authhash[:provider].capitalize}."
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
      :name => omniauth['user_info'] ? omniauth['user_info']['name'] : nil,
      :email => omniauth['user_info'] ? omniauth['user_info']['email'] : nil
    }
    session[:authhash] = @authhash
    auth = Service.find_by_provider_and_uid(@authhash[:provider], @authhash[:uid])
    if auth
      reset_session
      session[:user_id] = auth.user.id
      session[:service_id] = auth.id
      redirect_to root_path, :notice => "Signed in successfully via #{@authhash[:provider].capitalize}."
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
end
