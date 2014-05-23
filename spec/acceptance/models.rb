require 'anima'

class Scholar
  include Anima.new(:name, :pinyin, :latinized, :works)
end

class Work
  include Anima.new(:chinese_name, :english_name)
end

class LiteratureBaseMapper < Yaks::Mapper
  link :profile, 'http://literature.example.com/profiles/{mapper_name}'
end

class ScholarMapper < LiteratureBaseMapper
  attributes :name, :pinyin, :latinized
  has_many :works
  link :self, "http://literature.example.com/authors/{downcased_pinyin}"

  def downcased_pinyin
    object.pinyin.downcase
  end
end

class WorkMapper < LiteratureBaseMapper
  attributes :chinese_name, :english_name
end
