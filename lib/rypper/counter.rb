# -*- encoding: utf-8 -*-

module Rypper
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
end
