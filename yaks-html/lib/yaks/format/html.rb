# -*- coding: utf-8 -*-

module Yaks
  class Format
    class HTML < self
      include Util

      register :html, :html, 'text/html'

      def template
        @template ||= Hexp.parse(File.read(File.expand_path('../template.html', __FILE__)))
      end

      def section(name)
        template.find(".#{name}")
      end

      def serialize_resource(resource)
        template.replace('.resource') do |_|
          render(resource)
        end.replace('.yaks-version') do |ver|
          ver.content(Yaks::VERSION)
        end.replace('.request-info') do |req|
          req.content(env['REQUEST_METHOD'], ' ', env['PATH_INFO'])
        end
      end

      def render(*args)
        object = args.first
        type = object.class.name.split('::').last
        send("render_#{underscore(type)}", *args)
      end

      def render_resource(resource, templ = section('resource'))
        templ
          .replace('.type') { |header| header.content(resource.type.to_s + (resource.collection? ? ' collection' : '')) }
          .replace('.attribute', &render_attributes(resource.attributes))
          .replace('.links') {|links| resource.links.empty? ? [] : links.replace('.link', &render_links(resource.links)) }
          .replace('.forms') {|div| render_forms(resource.forms).call(div) }
          .replace('.subresource') {|sub_templ| render_subresources(resource, templ, sub_templ) }
      end
      alias render_collection_resource render_resource
      alias render_null_resource render_resource

      def render_attributes(attributes)
        ->(templ) do
          attributes.map do |key, value|
            templ
              .replace('.name')  {|x| x.content(key.to_s) }
              .replace('.value') {|x| x.content(value.inspect) }
          end
        end
      end

      def rel_href(rel)
        if rel.is_a?(Symbol)
          "http://www.iana.org/assignments/link-relations/link-relations.xhtml"
        else
          rel.to_s
        end
      end

      def render_links(links)
        ->(templ) do
          links.map do |link|
            templ
              .replace('.rel a') {|a|
                a.attr('href', rel_href(link.rel)).content(link.rel.to_s)
              }
              .replace('.uri a') {|a|
                a.attr('href', link.uri).content(link.uri)
                 .attr('rel', link.rel.to_s)
              }
              .replace('.title') {|x| x.content(link.title.to_s) }
              .replace('.templated') {|x| x.content(link.templated?.inspect) }
          end
        end
      end

      def render_subresources(resource, templ, sub_templ)
        templ = templ
                  .replace('h1,h2,h3,h4') {|h| h.set_tag("h#{h.tag[/\d/].to_i.next}") }
                  .add_class('collapsed')
        if resource.collection?
          resource.seq.map do |r|
            render(r, templ)
          end
        else
          resource.subresources.map do |resources|
            rel = resources.rels.first
            sub_templ
              .replace('.rel a') {|a| a.attr('href', rel_href(rel)).content(rel.to_s) }
              .replace('.value') {|x| x.content(resources.seq.map { |resource| render(resource, templ) })}
              .attr('rel', rel.to_s)
          end
        end
      end

      def render_forms(forms)
        ->(div) do
          div.content(
            forms.map(&method(:render))
          )
        end
      end

      def render_form(form_control)
        form = H[:form]
        form = form.attr('name', form_control.name)          if form_control.name
        form = form.attr('method', form_control.method)      if form_control.method
        form = form.attr('action', form_control.action)      if form_control.action
        form = form.attr('enctype', form_control.media_type) if form_control.media_type

        rows = form_control.fields.map(&method(:render))
        rows << H[:tr, H[:td], H[:td, H[:input, {type: 'submit'}]]]

        H[:div,
          H[:h4, form_control.title || form_control.name.to_s],
          form.content(H[:table, rows])]
      end

      def render_field(field)
        extra_info = reject_keys(field.to_h_compact, :type, :name, :value, :label, :options)
        H[:tr,
          H[:td,
            H[:label, {for: field.name}, [field.label || field.name.to_s, field.required ? '*' : ''].join]],
          H[:td,
            case field.type
            when /select/
              H[:select, reject_keys(field.to_h_compact, :options), render_select_options(field.options)]
            when /textarea/
              H[:textarea, reject_keys(field.to_h_compact, :value), field.value || '']
            when /hidden/
              [ field.value.inspect,
                H[:input, field.to_h_compact]
              ]
            else
              H[:input, field.to_h_compact]
            end],
          H[:td, extra_info.empty? ? '' : extra_info.inspect]
         ]
      end

      def render_fieldset(fieldset)
        legend = fieldset.fields.find {|field| field.type == :legend}
        fields = fieldset.fields.reject {|field| field.type == :legend}
        legend = legend ? legend.label : ''

        H[:tr,
          H[:th, legend],
          H[:td, H[:fieldset, H[:table, fields.map(&method(:render))]]]]
      end

      def render_select_options(options)
        options.map do |o|
          H[:option, reject_keys(o.to_h_compact, :label), o.label]
        end
      end
    end
  end
end
