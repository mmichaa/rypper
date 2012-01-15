# -*- encoding: utf-8 -*-

module Rypper
  class URI
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
      ::URI.parse(self.to_s)
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
end
