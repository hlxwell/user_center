class UsersController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create, :activate]

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new params[:user]
    respond_to do |format|
      format.html {
        if @user.save
          auto_login @user
          if cookies[:service]
            issue_service_ticket
          else
            redirect_to root_url, :notice => 'Registration successfull. Check your email for activation instructions.'
          end
        else
          render :action => "new"
        end
      }
    end
  end

  def update
    @user = User.find params[:id]
    respond_to do |format|
      format.html {
        if @user.update_attributes(params[:user])
          redirect_to(edit_user_path(@user), :notice => 'User was successfully updated.')
        else
          render :action => "edit"
        end
      }
    end
  end

  def activate
    if @user = User.load_from_activation_token(params[:id])
      @user.activate!
      redirect_to(login_path, :notice => 'User was successfully activated.')
    else
      not_authenticated
    end
  end

end
