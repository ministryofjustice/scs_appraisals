class GDSFormBuilder < ActionView::Helpers::FormBuilder
  attr_reader :template, :object_name

  def text_area(method, **options)
    with_label(method) {
      super(method, add_class(options, 'text form-control'))
    }
  end

  def bold_label(method, text: nil, **options)
    label(method, text, add_class(options, 'form-label-bold'))
  end

  def radio_buttons(method, values, labeler: labeler, **options)
    radio_button_fieldset(method, options) {
      with_label(method) {
        join(values.map.with_index { |value, i|
          label(method, value: value, class: "block-label index-#{i}") {
            radio_button(method, value) + labeler.call(value)
          }
        })
      }
    }
  end

  def text_field(method, **options)
    with_label(method) {
      super(method, add_class(options, 'form-control'))
    }
  end

  def password_field(method, **options)
    with_label(method) {
      super(method, add_class(options, 'form-control'))
    }
  end

  def file_field(method, **options)
    with_label(method) {
      super(method, add_class(options, 'form-control'))
    }
  end

  def collection_select(method, values, valuer: nil, labeler: nil, **options)
    valuer ||= ->(a) { a.respond_to?(:to_param) ? a.to_param : a }
    labeler ||= ->(a) { a }
    with_label(method) {
      template.content_tag(:div, class: 'custom-select fa-caret-down') {
        super(
          method, values, valuer, labeler, options,
          class: 'select form-control'
        )
      }
    }
  end

  def button(value = nil, **options)
    super(value, add_class(options, 'button'))
  end

  def with_label(method, &content)
    error_messages = object.errors[method].map { |error|
      template.content_tag(:p, class: 'error') { error }
    }.join.html_safe
    bold_label(method) + content.call + error_messages
  end

  def add_class(options, klass)
    options.merge(class: [options[:class], klass].compact.join(' '))
  end

private

  def radio_button_fieldset(method, options, &blk)
    id = [object_name, method].join('_')
    klass = options[:inline] ? 'inline' : ''
    template.content_tag(:fieldset, id: id, class: klass, &blk)
  end

  def join(items)
    items.inject(ActiveSupport::SafeBuffer.new, &:concat)
  end
end
