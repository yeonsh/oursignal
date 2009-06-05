class OpenId < Merb::Controller
  before :ensure_authenticated, :exclude => [:signup]
  before :ensure_openid_url, :only => [:signup]

  def login
    # if the user is logged in, then redirect them to their profile
    redirect url(:edit_user, session.user.id), :message => {:notice => 'You are now logged in.'}
  end

  def logout
    session.abandon!
    redirect '/'
  end

  def signup
    attributes = {
      :name         => session['openid.nickname'],
      :email        => session['openid.email'],
      :identity_url => session['openid.url'],
    }

    user = Merb::Authentication.user_class.first_or_create(
      attributes.only(:identity_url),
      attributes.only(:name, :email)
    )

    if user.update(attributes)
      session.user = user
      redirect url(:user, session.user.id), :message => {:notice => 'Signup was successful'}
    else
      message[:error] = 'There was an error while creating your user account'
      redirect(url(:openid))
    end
  end
  private

  def ensure_openid_url
    throw :halt, redirect(url(:openid)) if session['openid.url'].nil?
  end
end
