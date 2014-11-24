# -*- coding: utf-8 -*-

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
        raw = form.to_h
        raw[:href]  = raw.delete(:action)
        raw[:fields] = form.fields.map do |field|
          field.to_h.each_with_object({}) do |(attr,value), hsh|
            if attr == :options
              if !value.empty?
                hsh[:options] = value.map(&:to_h)
              end
            elsif HTML5Forms::FIELD_OPTIONS[attr] != value
              hsh[attr] = value
            end
          end
        end
        raw
      end
    end
  end
end
