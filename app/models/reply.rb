# frozen_string_literal: true

# Allows community members to reply to forum topics. Replies can also be nested
# under other replies.
class Reply < ActiveRecord::Base
  # Constants
  THRESHOLD = -10

  # Concerns
  include Deletable

  # Named Scopes

  # Model Validation
  validates :description, :user_id, :chapter_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :chapter
  belongs_to :reply
  has_many :reply_users

  # Model Methods

  def rank
    reply_users.sum(:vote)
  end

  def reverse_rank
    -rank
  end

  def order_newest
    -id
  end

  def order_oldest
    id
  end

  def order_best
    [reverse_rank, order_newest]
  end

  def below_threshold?
    deleted? || rank < THRESHOLD
  end

  def vote(current_user)
    reply_user = reply_users.find_by(user: current_user)
    return nil unless reply_user
    case reply_user.vote
    when 1
      true
    when -1
      false
    end
  end

  def parent_comment_id
    reply_id || 'root'
  end

  def computed_level
    return 0 if reply_id.nil?
    reply.computed_level + 1
  end

  def editable_by?(current_user)
    current_user.editable_replies.where(id: id).count == 1
  end

  def create_notifications!
    if reply
      notify_comment_author
    else
      notify_blog_author
    end
  end

  def notify_comment_author
    return if reply.user == user
    notification = reply.user.notifications.where(chapter_id: chapter_id, reply_id: id).first_or_create
    notification.mark_as_unread!
  end

  def notify_blog_author
    return if chapter.user == user
    notification = chapter.user.notifications.where(chapter_id: chapter_id, reply_id: id).first_or_create
    notification.mark_as_unread!
  end
end
