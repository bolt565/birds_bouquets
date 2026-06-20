class CleanupExpiredCartsJob < ApplicationJob
  queue_as :cleanup

  def perform
    # Rails sessions are managed by the cookie store by default (no DB cleanup needed).
    # This job is a placeholder for session store cleanup if using DB-backed sessions.
    Rails.logger.info("[CleanupExpiredCartsJob] Cart cleanup run at #{Time.current}")
  end
end
