require 'hammer/parser'
require 'bourbon'

module Hammer

  class CSSParser < Parser

    def to_format(format)
      if format == :css
        to_css
      else
        false
      end
    end

    def to_css
      @text || @hammer_file.raw_text
    end

    def parse(text)
      @text = text

      text = includes(text)
      text = clever_paths(text)
      text = url_paths(text)
      text = import_url_paths(text)
      return text
    end

    register_as_default_for_extension :css
    accepts :css
    returns :css

  private

    def ignore_file_path?(file_path)
      file_path == "" || file_path[0..3] == "http" || file_path[0..1] == "//" || file_path[0..4] == "data:" || file_path[0..0] == "/"
    end

    def import_url_paths(text)
      replace(text, /@import "(\S*?)"/) do |url_tag, line_number|

        file_path = url_tag.gsub('@import ', '').gsub('"', '').gsub(";", "").strip

        if ignore_file_path?(file_path)
          url_tag
        else
          add_wildcard_dependency file_path
          file_name = file_path.split(/\?|#/)[0]
          file = find_file_with_dependency(file_name)

          if file
            url = path_to(file)
            "@import \"#{url}\";"
          else
            url_tag
          end
        end
      end
    end

    def url_paths(text)
      replace(text, /url\((\S*?)\)/) do |url_tag, line_number|

        file_path = url_tag.gsub('"', '').gsub("url(", "").gsub(")", "").strip.gsub("'", "")

        if ignore_file_path?(file_path)
          url_tag
        else

          add_wildcard_dependency file_path
          file_name = file_path.split(/\?|#/)[0]
          extras = file_path.split(file_name)[1]

          file = find_files(file_name)[0]

          if file
            url = path_to(file)
            "url(#{url}#{extras if extras})"
          else
            url_tag
          end
        end
      end
    end

    def clever_paths(text)
      replace(text, /\/\* @path (.*?) \*\//) do |tag, line_number|

        file_path = tag.gsub('/* @path ', '').gsub("*/", "").strip

        if ignore_file_path?(file_path)
          tag
        else

          add_wildcard_dependency file_path
          file_name = file_path.split(/\?|#/)[0]
          file = find_files(file_name)[0]

          file ? path_to(file) : tag
        end
      end
    end

    def includes(text)
      lines = []
      replace(text, /\/\* @include (.*) \*\//) do |tag, line_number|
        return tag if tag.include? "("

        tags = tag.gsub("/* @include ", "").gsub("*/", "").strip.split(" ")
        a = tags.map do |tag|
          # TODO!
          # add_wildcard_dependency tag
          file = find_file_with_dependency(tag, 'css')
          raise "Included file <b>#{tag}</b> couldn't be found." unless file
          parse_file(file, :css)
        end
        a.compact.join("\n")
      end
    end
  end

end