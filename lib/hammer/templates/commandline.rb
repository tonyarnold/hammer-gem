require 'lib/hammer/templates/base'

module Hammer
  class CommandLineTemplate < Template
    def to_s
      # files.each do |data|
        # puts "#{data[:filename]}: compiled to #{data[:output_filename]}"
        # data.keys.each do |key|
          # next unless key == :error
          # puts "  #{key}: #{data[key]}" if data[key]
        # end
      # end
    end
  end
end