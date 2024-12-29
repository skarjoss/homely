# Main Homely Class
class Homely
  def self.configure(config, settings)

    # Configure Local Variable To Access Scripts
    script_dir = File.dirname(__FILE__)
    
    # Run folder for php must exists
    inline = "sudo mkdir -p /run/php/"  
    config.shell.provision "Configuring PHP run directory", type: "inline", inline: inline

    # Install opt-in features
    if settings.has_key?('features')

      #config.shell.provision "apt_update", type: "inline", inline: "apt-get update"

      # Ensure we have PHP versions used in sites in our features
      if settings.has_key?('sites')
        settings['sites'].each do |site|
          if site.has_key?('php')
            settings['features'].push({"php" + site['php'] => true})
          end
        end
      end

      settings['features'].each do |feature|
        feature_name = feature.keys[0]
        feature_variables = feature[feature_name]
        feature_path = script_dir + "/features/" + feature_name + ".sh"

        # Check for boolean parameters
        # Compares against true/false to show that it really means "<feature>: <boolean>"
        if feature_variables == false
          config.shell.provision "Features", type: "inline", inline: "echo Ignoring feature: #{feature_name} because it is set to false \n"
          next
        elsif feature_variables == true
          # If feature_arguments is true, set it to empty, so it could be passed to script without problem
          feature_variables = {}
        end

        # Check if feature really exists
        if !File.exist? File.expand_path(feature_path)
          config.shell.provision "Features", type: "inline", inline: "echo Invalid feature: #{feature_name} \n"
          next
        end

        name = "Installing " + feature_name
        path = feature_path
        env = feature_variables
        
        config.shell.provision name, type: "file", path: path, env: env
      end
    end

    # Enable Services
    if settings.has_key?('services')
      settings['services'].each do |service|
        service['enabled'].each do |enable_service|
          config.shell.provision "enable #{enable_service}", type: "inline", inline: "sudo systemctl enable #{enable_service}"
          config.shell.provision "start #{enable_service}", type: "inline", inline: "sudo systemctl start #{enable_service}"
        end if service.include?('enabled')

        service['disabled'].each do |disable_service|
          config.shell.provision "disable #{disable_service}", type: "inline", inline: "sudo systemctl disable #{disable_service}"
          config.shell.provision "stop #{disable_service}", type: "inline", inline: "sudo systemctl stop #{disable_service}"
        end if service.include?('disabled')
      end
    end

    # Clear any existing nginx sites
    path = script_dir + '/clear-nginx.sh'
    config.shell.provision "Clear Nginx", type: "file", path: path

    # Clear any Homely sites and insert markers in /etc/hosts
    path = script_dir + '/hosts-reset.sh'
    config.shell.provision "Clear site from hosts", type: "file", path: path

    # Install All The Configured Nginx Sites
    if settings.include? 'sites'

      domains = []

      settings['sites'].each do |site|

        domains.push(site['map'])

        # Create SSL certificate
        name = 'Creating Certificate: ' + site['map']
        path = script_dir + '/create-certificate.sh'
        args = [site['map']]
        config.shell.provision name, type: "file", path: path, args: args

        siteType = site['type'] ||= 'laravel'
        http_port = '80'
        https_port = '443'

        case siteType
        when 'apigility'
          siteType = 'zf'
        when 'expressive'
          siteType = 'zf'
        when 'symfony'
          siteType = 'symfony2'
        end

        # Create site in nginx
        name = 'Creating Site: ' + site['map']
        # Convert the site & any options to an array of arguments passed to the
        # specific site type script (defaults to laravel)
        path = script_dir + "/site-types/#{siteType}.sh"
        args = [
            site['map'],                # $1
            site['to'],                 # $2
            site['port'] ||= http_port, # $3
            site['ssl'] ||= https_port, # $4
            site['php'] ||= '8.1',      # $5
            params ||= '',              # $6
            site['xhgui'] ||= '',       # $7
            site['exec'] ||= 'false',   # $8
            headers ||= '',             # $9
            rewrites ||= '',            # $10
            site['api'] ||= '',         # $11
            site['path1'] ||= '',       # $12
            site['proxy1'] ||= ''       # $13
        ]
        config.shell.provision name, type: "file", path: path, args: args

        # adds site to hosts file
        path = script_dir + "/hosts-add.sh"
        args = ['127.0.0.1', site['map']]
        config.shell.provision "Adding site to hosts", type: "file", path: path, args: args

        # Configure The Cron Schedule
        if site.has_key?('schedule')
            name = 'Creating Schedule'
            if site['schedule']
              path = script_dir + '/cron-schedule.sh'
              args = [site['map'].tr('^A-Za-z0-9', ''), site['to'], site['php'] ||= '']
              config.shell.provision name, type: "file", path: path, args: args
            else
              siteName = site['map'].tr('^A-Za-z0-9', '')
              inline = "rm -f /etc/cron.d/#{siteName}"
              config.shell.provision name, type: "inline", inline: inline
            end
        else
          siteName = site['map'].tr('^A-Za-z0-9', '')
          inline = "rm -f /etc/cron.d/#{siteName}"
          config.shell.provision 'Checking for old Schedule', type: "inline", inline: inline
        end
      end
    end

    # Force to restart cron
    config.shell.provision 'Restarting Cron', type: "inline", inline: 'sudo service cron restart'

    # Force to restart webserver (nginx or apache)
    path = script_dir + '/restart-webserver.sh'
    config.shell.provision 'Restart Webserver', type: "file", path: path

    # Change PHP CLI version based on configuration
    if settings.has_key?('php') && settings['php']
        #inline = "sudo update-alternatives --set php /usr/bin/php#{settings['php']}; sudo update-alternatives --set php-config /usr/bin/php-config#{settings['php']}; sudo update-alternatives --set phpize /usr/bin/phpize#{settings['php']}"
        
        inline = "sudo update-alternatives --set php /usr/bin/php#{settings['php']}"
        
        config.shell.provision "Changing PHP CLI Version", type: "inline", inline: inline
    end

  end

end
