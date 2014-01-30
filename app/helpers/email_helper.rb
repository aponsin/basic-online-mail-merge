module EmailHelper
  def form_error_messages!(resource, options = {})
    return "" if resource.errors.empty?

    div_element(options) do
      html = error_title(resource)
      html += content_tag(:ul) do
        error_messages(resource)
      end
    end.html_safe
  end

  private
    def div_element(options, &block)
      content_tag(:div, {
        id:     options.fetch(:id, 'error_explanation'),
        class:  options.fetch(:class, ''),
        style:  options.fetch(:style, ''),
        data:   options.fetch(:data, {}),
      }) do
        block.call
      end
    end

    def error_title(resource)
      content_tag(:h2, "Erreur dans le formulaire:")
    end

    def error_messages(resource, embedded_resource = {})
      messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }
      embedded_resource.each do |embedded|
        embed = resource.send(embedded)
        if embed.is_a?(Array)
          embed.each do |embed|
            messages += embed.errors.full_messages.map { |msg| content_tag(:li, msg) }
          end
        else
          messages += embed.errors.full_messages.map { |msg| content_tag(:li, "#{embedded} - #{msg}") }
        end
      end

      messages.join.html_safe
    end
end
