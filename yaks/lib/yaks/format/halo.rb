# -*- coding: utf-8 -*-

module Yaks
  class Format
    # Extension of Hal loosely based on the example by Mike Kelly given at
    # https://gist.github.com/mikekelly/893552
    class Halo < Hal
      register :halo, :json, 'application/halo+json'

      def serialize_resource(resource)
        if resource.controls.any?
          super.merge(_controls: serialize_controls(resource.controls))
        else
          super
        end
      end

      def serialize_controls(controls)
        controls.each_with_object({}) do |control, result|
          result[control.name] = serialize_control(control)
        end
      end

      def serialize_control(control)
        control.to_h.merge(fields: control.fields.map(&:to_h))
      end
    end
  end
end
