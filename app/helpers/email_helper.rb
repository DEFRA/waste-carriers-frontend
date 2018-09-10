module EmailHelper

  # This ensures that an images we need to display in an email are shown by
  # adding them as attachments rather than exposing them as links to the
  # service. We have found this a more reliable method and is the same used as
  # in WEX and FRAE
  def email_image_tag(image, **options)
    path = "app/assets/images/#{image}"

    full_path = Rails.root.join path

    unless File.exist? full_path
      full_path = "#{path}"
    end

    attachments[image] = File.read full_path
    image_tag attachments[image].url, **options
  end
end
