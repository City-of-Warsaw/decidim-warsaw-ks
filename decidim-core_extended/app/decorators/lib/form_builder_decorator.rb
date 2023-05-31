# frozen_string_literal: true

require "foundation_rails_helper/form_builder"

Decidim::FormBuilder.class_eval do
  include ActionView::Helpers::AssetUrlHelper

  # Overwritten
  # Public: Generates a field for hashtaggable type.
  # type - The form field's type, like `text_area` or `text_input`
  # name - The name of the field
  # handlers - The social handlers to be created
  # options - The set of options to send to the field
  #
  # Renders form fields for each locale.
  def hashtaggable_text_field(type, name, locale, options = {})
    options[:hashtaggable] = true if type.to_sym == :editor
    required = attribute_required?(name)

    # Check if the field has the translatable_presence validation
    has_presence_validation = object.class.validators_on(name).any? do |validator|
      validator.is_a?(TranslatablePresenceValidator)
    end

    # Add the asteriks only if the field does not have the translatable_presence validation
    unless has_presence_validation
      options[:label] += required_indicator if required
    end

    content_tag(:div, class: "hashtags__container relative") do
      if options[:value]
        send(type, name_with_locale(name, locale), options.merge(label: options[:label], required: required, value: options[:value][locale]))
      else
        send(type, name_with_locale(name, locale), options.merge(label: options[:label], required: required))
      end
    end
  end

  def data_picker(attribute, options = {}, prompt_params = {})
    picker_options = {
      id: "#{@object_name}_#{attribute}",
      class: "picker-#{options[:multiple] ? "multiple" : "single"}",
      name: options[:name] || "#{@object_name}[#{attribute}]"
    }
    picker_options[:class] += " is-invalid-input" if error?(attribute)
    picker_options[:class] += " picker-autosort" if options[:autosort]

    items = object.send(attribute).collect { |item| [item, yield(item)] }

    template = ""
    template += label(attribute, label_for(attribute) + required_for_attribute(attribute, options)) unless options[:label] == false
    template += error_and_help_text(attribute, options)
    template += @template.render("decidim/widgets/data_picker", picker_options: picker_options, prompt_params: prompt_params, items: items)
    template.html_safe
  end

  def date_field(attribute, options = {})
    value = object.send(attribute)
    data = { datepicker: "" }
    data[:startdate] = I18n.l(value, format: :decidim_short) if value.present? && value.is_a?(Date)
    datepicker_format = ruby_format_to_datepicker(I18n.t("date.formats.decidim_short"))
    data[:"date-format"] = datepicker_format

    options[:help_text] ||= I18n.t("decidim.datepicker.help_text")

    template = text_field(
      attribute,
      options.merge(data: data, autocomplete: 'off')
    )

    template.html_safe
  end

  def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
    custom_label(attribute, options[:label], options[:label_options], options[:tooltip_helper], field_before_label: true) do
      options.delete(:label)
      options.delete(:label_options)
      @template.check_box(@object_name, attribute, objectify_options(options), checked_value, unchecked_value)
    end + error_and_help_text(attribute, options)
  end

  
  # Public: Generates a file upload field and sets the form as multipart.
  # If the file is an image it displays the default image if present or the current one.
  # By default it also generates a checkbox to delete the file. This checkbox can
  # be hidden if `options[:optional]` is passed as `false`.
  #
  # attribute    - The String name of the attribute to buidl the field.
  # options      - A Hash with options to build the field.
  #              * optional: Whether the file can be optional or not.
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def custom_upload(attribute, options = {})
    self.multipart = true
    options[:optional] = options[:optional].nil? ? true : options[:optional]
    label_text = options[:label] || label_for(attribute)
    alt_text = label_text

    file = object.send attribute
    template = ""
    template += label(attribute, label_text + required_for_attribute(attribute))
    template += upload_help(attribute, options)
    template += @template.file_field @object_name, attribute

    template += extension_allowlist_help(options[:extension_allowlist]) if options[:extension_allowlist].present?
    template += image_dimensions_help(options[:dimensions_info]) if options[:dimensions_info].present?

    if file_is_image?(file)
      template += if file.present?
                    @template.content_tag :label, I18n.t("current_image", scope: "decidim.forms")
                  else
                    @template.content_tag :label, I18n.t("default_image", scope: "decidim.forms")
                  end
      template += @template.content_tag :button, @template.image_tag(file.url, alt: "Zmień awatar"), type: "button", class: "wrapping-image", rel: "noopener"
    elsif file_is_present?(file)
      template += @template.label_tag I18n.t("current_file", scope: "decidim.forms")
      template += @template.link_to file.file.filename, file.url, target: "_blank", rel: "noopener"
    end

    if file_is_present?(file) && options[:optional]
      template += content_tag :div, class: "field" do
        safe_join([
                    @template.check_box(@object_name, "remove_#{attribute}"),
                    label("remove_#{attribute}", I18n.t("remove_this_file", scope: "decidim.forms"))
                  ])
      end
    end

    if object.errors[attribute].any?
      template += content_tag :p, class: "is-invalid-label" do
        safe_join object.errors[attribute], "<br/>".html_safe
      end
    end

    template.html_safe
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity 

  private

  def field(attribute, options, html_options = nil, &block)
    label = options.delete(:label)
    label_options = options.delete(:label_options)
    tooltip_helper = options.delete(:tooltip_helper)

    custom_label(attribute, label, label_options, tooltip_helper) do
      field_with_validations(attribute, options, html_options, &block)
    end
  end

  def custom_label(attribute, text, options, tooltip_helper, field_before_label: false, show_required: true)
    return block_given? ? yield.html_safe : "".html_safe if text == false

    hint = tooltip_helper || ''
    main_label = text.presence || default_label_text(object, attribute)
    main_label += required_for_attribute(attribute, hint) if show_required
    additional_hint = additional_hint(hint) if show_required

    final_input = if field_before_label && block_given?
                    safe_join([yield, additional_hint.html_safe])
                  elsif block_given?
                    safe_join([additional_hint.html_safe, yield])
                  end

    options = options ? options.merge(class: 'styled-label') : { class: 'styled-label' }

    if field_before_label
      (final_input + label(attribute, main_label, options)).html_safe
    else
      (label(attribute, main_label, options) + final_input).html_safe
    end
  end

  def field_with_validations(attribute, options, html_options)
    class_options = html_options || options
    aria_desc = options[:aria] ? options[:aria][:describedby] : ''

    if error?(attribute)
      class_options[:class] = class_options[:class].to_s
      class_options[:class] += " is-invalid-input"
    end

    help_text = options.delete(:help_text)
    prefix = options.delete(:prefix)
    postfix = options.delete(:postfix)

    unless self.object.class.name == 'Decidim::Projects::ProjectForm'
      class_options = extract_validations(attribute, options).merge(class_options)
    end

    content = yield(class_options)
    content += abide_error_element(attribute) if class_options[:pattern] || class_options[:required]
    content = content.html_safe
    html = wrap_prefix_and_postfix(content, prefix, postfix)
    new_help = help_text.present? ? content_tag(:span, help_text, class: "help-text", id: aria_desc) : ''
    new_error = error_for(attribute, options.merge(help_text: help_text))
    "#{new_help}#{html}#{new_error}".html_safe
  end

  # overwritten
  # FIX finding validators for translated attributes
  def find_validator(attribute, klass)
    return unless object.respond_to?(:_validators)

    attribute_without_local = attribute.to_s.gsub('_pl', '')
    object._validators[attribute_without_local.to_sym].find { |validator| validator.class == klass }
  end

  def required_for_attribute(attribute, hint = nil)
    # fix missing required '*' for translated attributes
    asterix = if attribute_required?(attribute)
                visible_title = content_tag(:span, "*", "aria-hidden": true)
                screenreader_title = content_tag(
                  :span,
                  I18n.t("required", scope: "forms"),
                  class: "show-for-sr"
                )
                content_tag(
                  :span,
                  visible_title + screenreader_title,
                  # title: I18n.t("required", scope: "forms"),
                  # data: { tooltip: false, disable_hover: false, keep_on_hover: false },
                  # "aria-haspopup": false,
                  class: "label-required"
                ).html_safe
              else
                ''
              end
    asterix
  end

  def additional_hint(raw_hint)
    hint = if raw_hint.is_a?(Hash)
             raw_hint[:tooltip_helper]
           else
             raw_hint
           end

    if hint.present?
      visible_title = content_tag(:span, '', "aria-hidden": true)
      screenreader_title = content_tag(
        :span,
        hint,
        class: "show-for-sr"
      )
      content_tag(
        :span,
        visible_title + screenreader_title,
        title: hint,
        data: { tooltip: true, disable_hover: false, keep_on_hover: true },
        "aria-haspopup": true,
        class: "additional-hint",
        tabindex: 0
      ).html_safe
    else
      ''
    end
  end

  def abide_error_element(attribute)
    ''
  end

  def extract_validations(attribute, options)
    min_length = options.delete(:minlength) || length_for_attribute(attribute, :minimum) || 0
    max_length = options.delete(:maxlength) || length_for_attribute(attribute, :maximum)

    validation_options = {}
    validation_options[:pattern] = "^(.|[\n\r]){#{min_length},#{max_length}}$" if min_length.to_i.positive? || max_length.to_i.positive?
    validation_options[:required] = options[:required] || attribute_required?(attribute)
    validation_options[:'aria-required'] = options[:'aria-required']
    validation_options[:minlength] ||= min_length if min_length.to_i.positive?
    validation_options[:maxlength] ||= max_length if max_length.to_i.positive?
    validation_options
  end

  def required_indicator
    visible_title = content_tag(:span, "*", "aria-hidden": true)
    screenreader_title = content_tag(
      :span,
      I18n.t("required", scope: "forms"),
      class: "show-for-sr"
    )
    return content_tag(
      :span,
      visible_title + screenreader_title,
      title: I18n.t("required", scope: "forms"),
      data: { tooltip: true, disable_hover: false, keep_on_hover: true },
      "aria-haspopup": true,
      class: "label-required"
    ).html_safe
  end
end
