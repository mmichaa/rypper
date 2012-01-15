# -*- encoding: utf-8 -*-

module Rypper
  class CLI
    OPTS = [
      ['--help', '-h', GetoptLong::NO_ARGUMENT],
      ['--output', '-o', GetoptLong::REQUIRED_ARGUMENT],
      ['--overwrite', '-w', GetoptLong::NO_ARGUMENT],
    ]

    def self.getopt()
      opts = {}
      GetoptLong.new(*OPTS).each do |opt, arg|
        opt_sym = opt.sub('--', '').to_sym
        opt_type = OPTS.find {|e| e.first == opt}.last
        if opt_type == GetoptLong::NO_ARGUMENT
          opts[opt_sym] = true
        else
          opts[opt_sym] = arg
        end
      end
      opts
    end

    def self.main()
      opts = self.getopt()
      argv = ARGV
      if argv.count != 2
        puts "USAGE: ruby #{$0} <uri> <selector>"
        exit 1
      end
      uri = Rypper::URI.new(argv[0]) # 'http://www.mangafox.com/manga/history_s_strongest_disciple_kenichi/v[01-45:vol]/c[001-459:chap]/[1-99:pic].html'
      uri.parse!
      uri.first!
    
      extractor = nil
      extractor = Rypper::Extractor.new(argv[1]) # '#image'
      counter = uri.counter[uri.order.last]
    
      puts "Processing #{uri.uri} ..."
      while true
        html_uri = uri.to_uri
        puts " * #{html_uri} ..."
        html = Rypper::Loader.get(html_uri)
        if html.is_a?(String)
          extractor.extract!(html_uri, html).each do |image_uri|
            if image_uri.is_a?(String)
              image_path = uri.to_path(File.extname(image_uri))
              if opts.has_key?(:output)
                image_path = File.join(opts[:output], image_path)
              end
              print "   * #{image_uri} --> #{image_path} ..."
              if !File.exists?(image_path) || opts.has_key?(:overwrite)
                Rypper::Loader.mkdir!(File.dirname(image_path))
                image_file = File.open(image_path, 'w')
                image_file.binmode
                image_file.write(Rypper::Loader.get(image_uri))
                image_file.close
                puts ' OK'
              else
                puts ' Exists: Skipping'
              end
            else
              puts ' * Imageless'
            end
          end
        else
          counter.last!
          puts ' * Last'
        end
        uri.next!
        break if uri.first?
      end
      
      puts 'OK'
      
      exit 0
    end
  end
end
