module DeviseHelper
  def devise_error_messages!
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)

    html = <<-HTML
    <div id="error_explanation" class="validation-summary">
      <h2>#{sentence}</h2>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def devise_token_error_messages!
    return "" if resource.errors.empty?

    messages = resource.errors.map { |err| content_tag(:li, I18n.t("errors.messages.#{err}")) }.join
    sentence = I18n.t("errors.messages.not_saved",
    :count => resource.errors.count,
    :resource => resource.class.model_name.human.downcase)

    html = <<-HTML
    <div id="error_explanation">
      <ul class="heading-large">#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

end
