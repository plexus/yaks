module Yaks
  # Based on the HTML living standard over at WHATWG
  # https://html.spec.whatwg.org/multipage/forms.html
  #
  # Does not aim to be complete, does aim to be a strict subset.
  module HTML5Forms

    INPUT_TYPES = [
      :checkbox,
      :color,
      :date,
      :datetime,
      :datetime_local, # :datetime-local in the spec
      :email,
      :file,
      :hidden,
      :image,
      :month,
      :number,
      :password,
      :radio,
      :range,
      :reset,
      :search,
      :tel,
      :text,
      :time,
      :url,
      :week,

      :select,
      :textarea,
      :datalist
    ]

    FIELD_OPTIONS = {
      required: false,
      rows: nil,
      type: nil,
      value: nil,
      pattern: nil,
      maxlength: nil,
      minlength: 0,
      size: 20,
      readonly: false,
      multiple: false,
      min: nil,
      max: nil,
      step: nil,
      list: nil,
      placeholder: nil,
      checked: false
    }

  end
end
