module ProfilesHelper
  def profile_tag(user)
    content_tag :span do
      gravatar_image_tag(user.email) + ' ' + user.name
    end
  end

  def profile_link_tag(user)
    link_to profile_path(user) do
      profile_tag(user)
    end
  end
end
