class Hammer

  class CSSParser < HammerParser
    
    def to_css
      @hammer_file.raw_text
    end

    def parse
      includes
      clever_paths
      url_paths
      return @text
    end
    
    def self.finished_extension
      "css"
    end
    
  private

    def url_paths
      replace(/url\((\S*)\)/) do |url_tag, line_number|
        file_path = url_tag.gsub('"', '').gsub("url(", "").gsub(")", "").strip.gsub("'", "")

        if file_path[0..3] == "http" || file_path[0..1] == "//" || file_path[0..4] == "data:"
          url_tag
        else
          
          file = find_file(file_path)
          
          if file
            url = Pathname.new(file.filename).relative_path_from Pathname.new(File.dirname(filename))
            "url(#{url})"
          else
            url_tag
          end
        end
      end
    end
    
    def includes
      lines = []
      replace(/\/\* @include (.*) \*\//) do |tag, line_number|
        tags = tag.gsub("/* @include ", "").gsub("*/", "").strip.split(" ")
        a = tags.map do |tag|
          file = find_file(tag, 'css')
          Hammer.parser_for_hammer_file(file).to_css()
        end
        a.compact.join("\n")
      end
    end

    def clever_paths
    end
  end
  register_parser_for_extensions CSSParser, ['css']
  register_parser_as_default_for_extensions CSSParser, ['css']

  class SASSParser < HammerParser
    
    def format=(format)
      @format = format.to_sym
    end
    
    def format
      filename.split('.')[1].to_sym
    end
    
    def text=(new_text)
      super
      @raw_text = new_text
    end
    
    def to_css
      parse
    end
    
    def to_format(new_format)
      if new_format == :css
        parse
      elsif new_format == format
        @raw_text
      elsif format == :scss and new_format == :sass
        warn "SCSS to SASS isn't done"
        ""
      elsif format == :sass and new_format == :scss
        warn "SASS to SCSS isn't done"
        ""
      end
    end

    def parse
      semicolon = format == :scss ? ";\n" : "\n"
      @text = ["@import 'bourbon'", "@import 'bourbon-deprecated-upcoming'", @text].join(semicolon)
      
      includes()
      
      # Dir.chdir(@directory) # will be required
      
      @text = Sass::Engine.new(@text, options).render()
      @text
    end
    
    def self.finished_extension
      "css"
    end
    
    private
    
    def includes
      lines = []
      replace(/\/\* @include (.*) \*\//) do |tag, line_number|
        tags = tag.gsub("/* @include ", "").gsub("*/", "").strip.split(" ")
        replacement = []
        tags.each do |tag|
          file = find_file(tag, 'scss')
          parser = Hammer.parser_for_hammer_file(file)
          if parser.respond_to?(:to_format)
            replacement << parser.to_format(format)
          else
            replacement << file.raw_text
            # TODO: Check whether the file is compatible
            # raise "File #{file.filename} couldn't be included in #{filename}"
          end
        end
        replacement.compact.join("\n")
      end
    end
    
    def load_paths
      [
        (File.dirname(@hammer_file.full_path) rescue nil),
        File.join(File.dirname(__FILE__), "../../../vendor/gems/bourbon-*/app/assets/stylesheets")
      ].compact
    end

    def options
      {
        :syntax => format, 
        :load_paths => load_paths,
        :relative_assets => true,
        # :cache_location => @hammer_project.sass_cache_directory,
        :sass => sass_options
      }
    end
    
    def sass_options
      { :quiet => true, :logger => nil }
    end
  end
  register_parser_for_extensions SASSParser, ['sass', 'scss', 'css']
  register_parser_as_default_for_extensions SASSParser, ['sass', 'scss']
end