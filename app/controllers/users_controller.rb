class UsersController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create, :activate]

  def new
    @user = User.new
  end

  def create
    @user = User.new params[:user]

    respond_to do |format|
      format.html {
        if @user.save
          # auto_login @user
          redirect_to root_url, :notice => 'Registration successfull. Check your email for activation instructions.'
        else
          render :action => "new"
        end
      }
    end
  end

  def activate
    if @user = User.load_from_activation_token(params[:token])
      @user.activate!
      redirect_to(login_path, :notice => 'User was successfully activated. You can login this account now.')
    else
      not_authenticated
    end
  end

end
