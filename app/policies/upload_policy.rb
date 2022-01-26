# frozen_string_literal: true

class UploadPolicy < ApplicationPolicy
  def create?
    unbanned?
  end

  def show?
    user.is_admin? || record.uploader_id == user.id
  end

  def batch?
    unbanned?
  end

  def image_proxy?
    unbanned?
  end

  def permitted_attributes
    %i[file source tag_string rating status parent_id artist_commentary_title
       artist_commentary_desc referer_url
       md5_confirmation as_pending translated_commentary_title translated_commentary_desc]
  end
end
