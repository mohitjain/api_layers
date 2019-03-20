module AccessControlable
  def access_flag_set? current_user, access, key
    (current_user.is_super_admin?) || (access.present? && access[key] == true)
  end
end
