# -*- encoding: utf-8 -*-

require 'net/http_client'

require 'getoptlong'
require 'uri'

require 'rubygems'
require 'nokogiri'
require 'selenium-webdriver'

require 'rypper/cli'
require 'rypper/counter'
require 'rypper/extractor'
require 'rypper/loader'
require 'rypper/selenium'
require 'rypper/uri'

if File.basename($0) == __FILE__
  Rypper::CLI.main()
end
