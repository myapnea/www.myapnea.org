class Invite < ActiveRecord::Base

  before_create   :generate_token
  before_save     :check_existing_user

  belongs_to :user

  def generate_token
    self.token = Digest::SHA1.hexdigest([self.user_id, Time.now, rand].join)
  end

  def check_existing_user
    self.recipient_id = User.find_by_email(self.email).present? ? User.find_by_email(self.email).id : nil
  end

end
