module Yaks
  module Changelog
    module_function

    def current
      versions[Yaks::VERSION]
    end

    def versions
      markdown.split(/(?=###\s*[\d\w\.]+\n)/).each_with_object({}) do |section, hsh|
        version = section.each_line.first[/[\d\w\.]+/]
        log     = section.each_line.drop(1).join.strip
        hsh[version] = log
      end
    end

    def markdown
      Pathname(__FILE__).join('../../../../CHANGELOG.md').read
    end
  end
end
