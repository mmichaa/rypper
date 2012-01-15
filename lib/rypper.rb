# encoding: UTF-8

require 'net/http_client'

require 'uri'

require 'rubygems'
require 'nokogiri'

module Rypper
  class Uri
    REGEXP_COUNTER = /\[(\d+)\-(\d+)\:(\w+)\]/
    REGEXP_NAME = /\[\:(\w+)\]/

    attr_accessor :uri
    attr_reader :counter
    attr_reader :order

    def initialize(uri)
      self.uri = uri.to_s
    end

    def parse!
      @counter = {}
      @order = []
      self.uri.scan(REGEXP_COUNTER) do
        match = $~
        lower = match[1].to_i
        upper = match[2].to_i
        digits = match[1].start_with?('0') ? match[1].length : 1
        name = match[3].intern
        self.counter[name] = Counter.new(match.to_s, lower, upper, digits)
        self.order << name
      end
      self
    end

    def first!
      self.counter.each_value(&:first!)
      self
    end

    def first?
      self.counter.values.all?(&:first?)
    end

    def prev!
      self.order.reverse.each do |name|
        cntr = self.counter[name]
        if cntr.prev!.state != cntr.upper
          break
        end
      end
      self
    end

    def next!
      self.order.reverse.each do |name|
        cntr = self.counter[name]
        if cntr.next!.state != cntr.lower
          break
        end
      end
      self
    end

    def last!
      self.counter.each_value(&:last!)
      self
    end

    def last?
      self.counter.values.all?(&:last?)
    end

    def to_s
      s = self.uri.dup
      self.counter.each do |name, counter|
        value = counter.to_s
        s.gsub!(counter.match, value)
        s.gsub!(":[#{name}]", value)
      end
      s
    end

    def to_uri
      URI.parse(self.to_s)
    end

    def to_path(extension=nil, cntr_sep=nil, path_sep=nil, cdigits=nil)
      cntr_sep ||= '_'
      path_sep ||= File::Separator
      p = []
      self.order.each do |name|
        cnt = self.counter[name]
        p << name.to_s
        p << cntr_sep
        p << cnt.to_s(cdigits)
        p << path_sep
      end
      p.pop
      p << extension unless extension.nil?
      p.join()
    end
  end

  class Counter
    attr_reader :match
    attr_reader :lower
    attr_reader :upper
    attr_reader :digits
    attr_reader :state

    def initialize(match, lower, upper, digits=1, state=nil)
      @match = match
      @lower = lower
      @upper = upper
      @digits = digits
      @state = state || @lower
    end

    def first!
      @state = @lower
      self
    end

    def first?
      @state == @lower
    end

    def prev!
      if @state > @lower
        @state -= 1
      else
        @state = @upper
      end
      self
    end

    def next!
      if @state < @upper
        @state += 1
      else
        @state = @lower
      end
      self
    end

    def last!
      @state = @upper
      self
    end

    def last?
      @state == @upper
    end

    def to_s(digits=nil)
      digits ||= self.digits
      @state.to_s.rjust(digits, '0')
    end
  end

  class Loader
    def self.mkdir!(path)
      path = path.to_s
      parts = []
      path.split(File::Separator).each do |part|
        parts << part
        sub_path = File.join(*parts)
        Dir.mkdir(sub_path) unless File.directory?(sub_path)
      end
      File.directory?(path)
    end

    def self.get(uri)
      unless uri.kind_of?(URI)
        uri = URI.parse(uri.to_s)
      end
      client = Net::HTTPClient.from_storage(uri.host)
      response = client.get(uri)
      if response.code.to_i == 200
        response.body
      else
        response.code.to_i
      end
    end
  end

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


if File.basename($0) == __FILE__
  if ARGV.count != 2
    puts "USAGE: ruby #{$0} <uri> <selector>"
    exit 1
  end
  uri = Rypper::Uri.new(ARGV[0]) # 'http://www.mangafox.com/manga/history_s_strongest_disciple_kenichi/v[01-45:vol]/c[001-459:chap]/[1-99:pic].html'
  uri.parse!
  uri.first!

  extractor = nil
  extractor = Rypper::Extractor.new(ARGV[1]) # '#image'
  counter = uri.counter[uri.order.last]

  puts "Processing #{uri.uri} ..."
  while true
    html_uri = uri.to_uri
    puts " * #{html_uri} ..."
    html = Rypper::Loader.get(html_uri)
    if html.is_a?(String)
      extractor.extract!(html).each do |image_uri|
        if image_uri.is_a?(String)
          puts "   * #{image_uri} ..."
          image_path = uri.to_path(File.extname(image_uri))
          Rypper::Loader.mkdir!(File.dirname(image_path))
          image_file = File.open(image_path, 'w')
          image_file.binmode
          image_file.write(Rypper::Loader.get(image_uri))
          image_file.close
          puts '   * OK'
        else
          puts '   * Imageless!'
        end
      end
    else
      counter.last!
      puts ' * Last!'
    end
    uri.next!
    break if uri.first?
  end
  
  puts 'OK'
  
  exit 0
end
