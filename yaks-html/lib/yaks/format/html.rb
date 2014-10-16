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
          .replace('.subresources') {|table| resource.subresources.empty? ? [] : render_subresources(resource.subresources, templ).call(table) }
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

    end
  end
end
