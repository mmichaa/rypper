# -*- encoding: utf-8 -*-

module Rypper
  class Harmony
    def visit(uri)
      @page = ::Harmony::Page.new(html)
    end

    def source
      @page.to_html unless @page.nil?
    end
    alias :body :source

    def current_url
      @page.window.location.href unless @page.nil?
    end

    def execute_script(script)
      @page.execute_js(script) unless @page.nil?
    end
  end
end
