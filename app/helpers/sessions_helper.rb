module SessionsHelper


  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def log_in(user)
    session[:user_id] = user.id
  end
  # Возвращает текущего пользователя, осуществившего вход (если он есть).
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  # Забывает постоянную сессии.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  # Осуществляет выход текущего пользователя.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
  # Возвращает true, если заданный пользователь является текущим.
  def current_user?(user)
    user == current_user
  end

  # Перенаправляет к сохраненному расположению (или по умолчанию).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Сохраняет запрошенный URL.
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end
end
