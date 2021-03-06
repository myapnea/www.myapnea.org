# frozen_string_literal: true

# Allows users to be notified inside the web application of new replies to
# blog and forum posts and comments.
class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_notification_or_redirect, only: [:show, :update]
  before_action :set_broadcast_or_topic, only: [:mark_all_as_read]

  # GET /notifications
  def index
    @notifications = \
      if params[:all] == "1"
        current_user.notifications.where("notifications.created_at > ?", Time.zone.now - 7.days)
      else
        current_user.notifications.where(read: false)
      end
  end

  # GET /notifications/1
  def show
    @notification.update(read: true)
    redirect_to notification_redirect_path
  end

  # PATCH /notifications/1.js
  def update
    @notification.update(notification_params)
    render :show
  end

  # PATCH /notifications/mark_all_as_read
  def mark_all_as_read
    notification_ids = \
      if @broadcast
        current_user.notifications.where(broadcast_id: @broadcast.id, read: false).pluck(:id)
      elsif @topic
        current_user.notifications.where(topic_id: @topic.id, read: false).pluck(:id)
      else
        []
      end
    current_user.notifications.where(id: notification_ids).update_all(read: true)
    @notifications = current_user.notifications.where(id: notification_ids)
  end

  private

  def set_broadcast_or_topic
    @broadcast = Broadcast.current.published.find_by(id: params[:broadcast_id])
    @topic = Topic.current.find_by(id: params[:topic_id])
  end

  def find_notification_or_redirect
    @notification = current_user.notifications.find_by(id: params[:id])
    redirect_to notifications_path unless @notification
  end

  def notification_params
    params.require(:notification).permit(:read)
  end

  def notification_redirect_path
    return reply_path(@notification.reply) if @notification.reply
    return @notification.admin_export if @notification.admin_export
    notifications_path
  end
end
