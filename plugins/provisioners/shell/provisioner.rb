require 'open3'

module HomelyPlugins
  module Shell
    class Provisioner

      def provision(name, params)
        puts name
        config = OpenStruct.new(params)
        begin
          send(config.type, config)
        rescue => e
          puts "\e[31m Error: #{e.class} #{e.message} \e[0m"
        end
      end

      # Execute inline scripts
      def inline(config)
        # inline script is required
        return if config.inline.to_s.empty?
        # returns true if the inline command was successful
        return system(config.inline)
      end
      
      # Execute file scripts
      def file(config)
        # script path is required
        return if config.path.to_s.empty?
        # formats the args to strings
        args = ""
        if config.args.is_a?(String)
          args = " #{config.args.to_s}"
        elsif config.args.is_a?(Array)
          args = config.args.map { |a| quote_and_escape(a) }
          args = " #{args.join(" ")}"
        end
        # executes the string with the args, returns true if the inline command was successful
        @cmd = "#{config.path} #{args}"
        return system(@cmd)
      end

      # Quote and escape strings for shell execution
      def quote_and_escape(text, quote = '"')
        "#{quote}#{text.gsub(/#{quote}/) { |m| "#{m}\\#{m}#{m}" }}#{quote}"
      end
      
    end
  end
end