class UsersController < ApplicationController

  before_filter :signed_in_user  , only: [:edit, :update, :index, :destroy, :followers, :following]
  before_filter :unsigned_in_user, only: [:create, :new]
  before_filter  :correct_user , only: [:edit, :update]
  before_filter :admin_user, only: :destroy
  def new
  	@user=User.new
  end

  def index
        @users= User.paginate(:page=>params[:page])
  end

  def show
    @user=User.find(params[:id])
    @microposts= @user.microposts.paginate(page: params[:page])   # same as paginate(:page=>params[:page])
  end

  def update
    if @user.update_attributes(params[:user])
    # handle a successful update
      flash[:success]="Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def edit
  @user= User.find(params[:id])
  end

  def create
  @user=User.new(params[:user])
  if @user.save
    sign_in @user
    flash[:success] = "Welcome to the Sample App!"
    UserMailer.registration_confirmation(@user).deliver
  	redirect_to @user
  else
  	render 'new'
  end
  end


  def destroy
   User.find(params[:id]).destroy    # Here this destroy method is inbuilt method of Active record used to del a row
   flash[:success]="User destroyed"
   redirect_to users_path
  end

  def following
    @title='Following'
    @user=User.find(params[:id])  # this id corresponds to which user ? present user or user whose profile is clicked on ?..like /users/1...
   @users= @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title='Followers'
    @user=User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  def activate_email
    @user=User.find_by_email_token(params[:email_token])

    @user.update_attribute(:email_activated,true)
    sign_in @user
    flash[:success]= "Your email has been activated"
    redirect_to @user
  end

  private
   

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)

  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end

  def unsigned_in_user
    redirect_to root_path if signed_in?
  end
      
end

