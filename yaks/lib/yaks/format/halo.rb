module Yaks
  class Format
    # Extension of Hal loosely based on the example by Mike Kelly given at
    # https://gist.github.com/mikekelly/893552
    class Halo < Hal
      register :halo, :json, 'application/halo+json'

      def serialize_resource(resource)
        if resource.forms.any?
          super.merge(_controls: serialize_forms(resource.forms))
        else
          super
        end
      end

      def serialize_forms(forms)
        forms.each_with_object({}) do |form, result|
          result[form.name] = serialize_form(form)
        end
      end

      def serialize_form(form)
        raw = form.to_h_compact
        raw[:href]  = raw.delete(:action) if raw[:action]
        raw[:fields] = form.fields.map(&method(:serialize_form_field))
        raw
      end

      def serialize_form_field(field)
        if field.type == :fieldset
          {
            type: :fieldset,
            fields: field.fields.map(&method(:serialize_form_field))
          }
        else
          field.to_h_compact.each_with_object({}) do |(attr,value), hsh|
            if attr == :options # <option>s of a <select>
              if !value.empty?
                hsh[:options] = value.map(&:to_h_compact)
              end
            else
              hsh[attr] = value
            end
          end
        end
      end
    end
  end
end
