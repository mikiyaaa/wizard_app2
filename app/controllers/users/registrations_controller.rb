# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(sign_up_params)
    # 1ページ目で入力した情報のバリデーションチェック
    unless @user.valid?
      render :new and return
    end
    # 1ページ目で入力した情報をsessionに保持させること
    session["devise.regist_data"] = {user: @user.attributes} # ハッシュ型に値を変換
    # attributesメソッドでデータ整形をした際にパスワードの情報は含まれない。パスワードを再度sessionに代入する
    session["devise.regist_data"][:user]["password"] = params[:user][:password]
    # @userに紐づくインスタンスを生成
    @address = @user.build_address
    render :new_address
  end

  def create_address
    @user = User.new(session["devise.regist_data"]["user"])
    binding.pry
    @address = Address.new(address_params)
    binding.pry

    # 住所情報のバリデーションチェック
    unless @address.valid?
      render :new_address and return
    end

    # 住所情報とsessionで保持していたユーザー情報を合わせて保存
    @user.build_address(@address.attributes)
    binding.pry
    @user.save

    # sessionを削除
    session["devise.regist_data"]["user"].clear
    # ログインする
    sign_in(:user, @user)
  end

  private
  def address_params
    params.require(:address).permit(:postal_code, :address)
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
