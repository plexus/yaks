# -*- coding: utf-8 -*-

module Yaks
  class Format
    class HTML < self
      include Adamantium

      register :html, :html, 'text/html'

      def template
        Hexp.parse(File.read(File.expand_path('../template.html', __FILE__)))
      end
      memoize :template

      def section(name)
        template.select(".#{name}").first
      end

      def serialize_resource(resource)
        template.replace('body') do |body|
          body.content(render_resource(resource))
        end
      end

      def render_resource(resource, templ = section('resource'))
        templ
          .replace('.type') { |header| header.content(resource.type.to_s + (resource.collection? ? ' collection' : '')) }
          .replace('.attribute', &render_attributes(resource.attributes))
          .replace('.link', &render_links(resource.links))
          .replace('.links') {|links| resource.links.empty? ? [] : render_links(resource.links).call(links) }
          .replace('.controls') {|div| render_controls(resource.controls).call(div) }
          .replace('.subresource') {|table| resource.subresources.empty? ? [] : render_subresources(resource.subresources, templ).call(table) }
      end

      def render_attributes(attributes)
        ->(templ) do
          attributes.map do |key, value|
            templ
              .replace('.name')  {|x| x.content(key.to_s) }
              .replace('.value') {|x| x.content(value.inspect) }
          end
        end
      end

      def render_links(links)
        ->(templ) do
          links.map do |link|
            templ
              .replace('.rel a') {|a| a.attr('href', link.rel.to_s).content(link.rel.to_s) }
              .replace('.uri a') {|a| a.attr('href', link.uri).content(link.uri) }
              .replace('.title') {|x| x.content(link.title) }
              .replace('.templated') {|x| x.content(link.templated?.inspect) }
          end
        end
      end

      def render_subresources(subresources, templ)
        templ = templ.replace('h1,h2,h3,h4') {|h| h.set_tag("h#{h.tag[/\d/].to_i.next}") }
        ->(wrap) do
          wrap.replace('.subresource') { |row|
            subresources.map do |rel, resources|
              row
                .replace('.rel a') {|a| a.attr('href', rel.to_s).content(rel.to_s) }
                .replace('.value') {|x| x.content(resources.map { |resource| render_resource(resource, templ) })}
            end
          }
        end
      end


      def render_controls(controls)
        ->(div) do
          div.content(
            controls.map(&method(:render_control))
          )
        end
      end

      def render_control(control)
        form = H[:form]
        form = form.attr('name', control.name)          if control.name
        form = form.attr('method', control.method)      if control.method
        form = form.attr('action', control.href)        if control.href
        form = form.attr('enctype', control.media_type) if control.media_type

        rows = control.fields.map do |field|
          H[:tr,
            H[:td, H[:label, {for: field.name}, field.label || '']],
            H[:td, case field.type
                   when /\A(button|checkbox|file|hidden|image|password|radio|reset|submit|text)\z/
                     H[:input, type: field.type, value: field.value, name: field.name]
                   when /textarea/
                     H[:textarea, { name: field.name },  field.value || '']
                   end]
           ]
        end
        form.content(H[:table, control.title || '', *rows, H[:tr, H[:td, H[:input, {type: 'submit'}]]]])
      end
    end
  end
end
