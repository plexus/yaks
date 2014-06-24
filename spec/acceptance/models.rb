require 'anima'

class Scholar
  include Anima.new(:id, :name, :pinyin, :latinized, :works)
end

class Work
  include Anima.new(:id, :chinese_name, :english_name, :quotes, :era)
end

class Quote
  include Anima.new(:id, :chinese, :english, :sources)
end

class Era
  include Anima.new(:id, :name)
end

class LiteratureBaseMapper < Yaks::Mapper
  link :profile, 'http://literature.example.com/profiles/{mapper_name}'
  link :self, 'http://literature.example.com/{mapper_name}/{id}'
end

class ScholarMapper < LiteratureBaseMapper
  attributes :id, :name, :pinyin, :latinized
  has_many :works

  link 'http://literature.example.com/rels/quotes', 'http://literature.example.com/quotes/?author={downcased_pinyin}&q={query}', expand: [:downcased_pinyin]
  link :self, 'http://literature.example.com/authors/{downcased_pinyin}'

  def downcased_pinyin
    object.pinyin.downcase
  end
end

class WorkMapper < LiteratureBaseMapper
  attributes :id, :chinese_name, :english_name
  has_many :quotes
  has_one  :era
end

class QuoteMapper < Yaks::Mapper
  attributes :id, :chinese
end

class EraMapper < Yaks::Mapper
  attributes :id, :name
end
