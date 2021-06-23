class MessageSerializer < ActiveModel::Serializer
  attributes :id,
             :user_id,
             :user_type,
             :body,
             :created_at,
             :updated_at,
             :photo_url,
             :is_hidden,
             :author_name,
             :is_current_users_message

  def photo_url
    if (!object.photo_path.nil?)
      return FileHandler.new(Message.photo_bucket, object.photo_path).get_presigned_download_url
    end
    return ""
  end

  def user_type
    object.user.type
  end

  def author_name
    return object.user.full_name unless !allowed_to_see_name
  end

  def is_current_users_message
    return object.user_id == current_user.id
  end

  private

  def allowed_to_see_name
    object.user.patient? && Pundit.policy(current_user, object.user).show?
  end

  def current_user
    @instance_options[:current_user]
  end
end
