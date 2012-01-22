module Rypper
  class Akephalos
    def initialize(options={})
      @options = options
    end

    def browser
      @browser ||= ::Akephalos::Client.new(@options)
    end

    def visit(uri)
      browser.visit(uri.to_s)
    end
  
    def source
      page.source
    end
  
    def body
      body_source = page.modified_source
  
      if body_source.respond_to?(:force_encoding)
        body_source.force_encoding("UTF-8")
      else
        body_source
      end
    end
  
    def response_headers
      page.response_headers
    end
  
    def status_code
      page.status_code
    end
  
    def reset!
      cookies.clear
    end
    alias :cleanup! :reset!
  
    def current_url
      page.current_url
    end

    def execute_script(script)
      page.execute_script script
    end

    def evaluate_script(script)
      page.evaluate_script script
    end

    def page
      browser.page
    end

    def cookies
      browser.cookies
    end

    def user_agent
      browser.user_agent
    end
  end
end