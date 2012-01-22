# -*- encoding: utf-8 -*-

require 'net/http_client'

require 'getoptlong'
require 'uri'

require 'rubygems'
require 'akephalos'
require 'harmony'
require 'nokogiri'
require 'selenium-webdriver'

require 'rypper/akephalos'
require 'rypper/cli'
require 'rypper/counter'
require 'rypper/extractor'
require 'rypper/loader'
require 'rypper/selenium'
require 'rypper/uri'

module Rypper
  VERSION = '0.0.3'
end

if File.basename($0) == __FILE__
  Rypper::CLI.main()
end
