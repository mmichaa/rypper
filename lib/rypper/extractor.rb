# -*- encoding: utf-8 -*-

module Rypper
  class Extractor
    attr_reader :selector

    def initialize(selector)
      @selector = selector
    end

    def extract!(html)
      unless html.kind_of?(Nokogiri::HTML::Document)
        html = Nokogiri::HTML(html)
      end
      res = []
      elems = html.search(self.selector)
      if elems.count == 1
        elem = elems.first
        if elem.name == 'img'
          res << elem[:src]
        elsif elem.name == 'a'
          res << elem[:href]
        else
          res << elem
        end
      else
        res = elems
      end
      res
    end
  end
end