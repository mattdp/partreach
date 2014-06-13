module UsersHelper

  def admin?(user)
    user.admin
  end

  def examiner?(user)
    user.examiner
  end

end
