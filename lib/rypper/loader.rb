# -*- encoding: utf-8 -*-

module Rypper
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
        uri = ::URI.parse(uri.to_s)
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
end