# -*- encoding: utf-8 -*-

module Rypper
  class Extractor
    attr_reader :selector

    def self.dirname(uri)
      uri = uri.to_s
      dirname = nil
      if File.extname(uri).empty?
        dirname = uri
      else
        dirname = File.dirname(uri)
      end
      dirname.chomp!('/')
      dirname.concat('/')
      dirname
    end

    def initialize(selector)
      @selector = selector
    end

    def extract!(uri, html)
      uri = uri.to_s
      unless html.kind_of?(Nokogiri::HTML::Document)
        html = Nokogiri::HTML(html.to_s)
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
      res.map! do |elem|
        if elem.is_a?(String)
          elem_uri = ::URI.parse(elem)
          if !elem_uri.absolute?
            elem_uri = ::URI.join(self.dirname(uri), elem)
          elsif elem_uri.instance_of?(::URI::Generic) # absolute path only
            elem_uri = ::URI.parse(uri)
            elem_uri.path = elem
          end
          elem_uri.to_s
        else
          elem
        end
      end if res.is_a?(Array)
      res
    end
  end
end