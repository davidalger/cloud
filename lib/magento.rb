##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

 # # Example of call
 # install_magento2 node,
 #   host: 'demo',
 #   database: 'magento2_ce_my_theme',
 #   path: 'v2/community-my-theme',
 #   admin_pass: 'password',
 #   admin_user: 'admin',
 #   composer_package_list: [
 #     {
 #       package_name: "myname/theme-my-theme",
 #       package_version: "dev-develop",
 #       package_repository_path: "git git@bitbucket.org:myname/my-theme.git",
 #       ssh_host: "bitbucket.org",
 #       require_magentup_setup_upgrade: true,
 #       enable_magento_extension: "MyName_MyExtension",
 #       additional_commands_to_execute: [
 #         "bin/magento myname:myspecial:customcommand"
 #       ]
 #     }
 #   ],
 #   install_theme_code: "MyName/MyTheme"

def install_magento2 (
  node, 
  host: nil, 
  path: nil, 
  database: nil, 
  enterprise: false, 
  sampledata: true,
  admin_pass: nil, 
  admin_user: 'admin',
  composer_package_list: [],
  install_theme_code: nil,
  extra_configs: []
  )
    
  host = host + '.' + CLOUD_DOMAIN
  flag_ee = enterprise ? ' -e ' : nil
  flag_sd = sampledata ? ' -d ' : nil
  
  node.vm.provision :shell do |conf|
    conf.name = "install_magento2:#{host}/#{path}"
    
    opt_urlpath = ''
    if path
      opt_urlpath = "--urlpath=#{path}"
    end
    
    composer_packages=''
    package_repositories=''
    ssh_host_keys=''
    if composer_package_list.length > 0
      composer_package_list.each { |package|
        if package.key?(:ssh_host)
          ssh_host_keys.concat("
          [ $(cat ~/.ssh/known_hosts | grep #{package[:ssh_host]} | wc -l) -eq 0 ] && ssh-keyscan #{package[:ssh_host]} >> ~/.ssh/known_hosts
          ")
        end
        if package.key?(:package_repository_path)
          package_repositories.concat("
          composer config repositories.#{package[:package_name]} #{package[:package_repository_path]}
          ")
        end
        composer_packages.concat("
        composer require #{package[:package_name]}:#{package[:package_version]}
        ")
        if package.key?(:enable_magento_extension)
          composer_packages.concat("
          bin/magento module:enable --clear-static-content #{package[:enable_magento_extension]} -q
          ")
        end
        if package.key?(:require_magentup_setup_upgrade)
          composer_packages.concat("
          bin/magento setup:upgrade -q
          bin/magento cache:flush -q
          ")
        end
        if package.key?(:additional_commands_to_execute)
          package[:additional_commands_to_execute].each { |additional_command|
            composer_packages.concat("
            #{additional_command}
            ")
          }
        end
      }
    end
    
    theme_package_installation=''
    if install_theme_code
      theme_package_installation="
      echo 'setting theme #{install_theme_code} as the default theme'
      # After installing the theme a db upgrade is required to populate the theme table in the db with
      # a record so we can query the db for a theme_id to set
      bin/magento setup:db-data:upgrade -q
      THEME_ID=$(
        echo \"select theme_id from theme where code = '#{install_theme_code}';\" \
        | mysql -D #{database} --batch --skip-column-names --default-character-set=utf8
      )
      mr2 config:set design/theme/theme_id ${THEME_ID}
      "
    end
    
    additional_configurations=''
    if extra_configs.length > 0
      extra_configs.each { |additional_config|
        additional_configurations.concat("
        #{additional_config}
        ")
      }
    end
    
    conf.inline = "
      set -e
      
      cd #{VAGRANT_DIR}
      source ./scripts/lib/utils.sh
      
      start_time=$(capture_nanotime)
      
      export DB_HOST=localhost
      export DB_NAME=#{database}
      export INSTALL_DIR=/var/www/magento2/#{path}
      export ADMIN_PASS='#{admin_pass}'
      
      echo 'Running subscript: m2setup.sh'
      m2setup.sh #{flag_sd} #{flag_ee} --hostname=#{host} #{opt_urlpath} \
              --admin-user=#{admin_user} --secure-everywhere --no-compile
      ln -s $INSTALL_DIR/pub $INSTALL_DIR/pub/pub     # todo: remove temp fix when GH Issue #2711 is resolved
      
      cd $INSTALL_DIR
      
      echo 'Installing any composer repositories and packages'
      
      #{ssh_host_keys}
      #{package_repositories}
      #{composer_packages}
      
      echo 'Initializing any composer magento themes'
      #{theme_package_installation}
      
      echo 'Initializing software configuration'
      
      bin/magento deploy:mode:set --skip-compilation production
      
      mr2 -q --skip-root-check config:set dev/css/merge_css_files 1
      mr2 -q --skip-root-check config:set dev/js/merge_files 1
      mr2 -q --skip-root-check config:set dev/static/sign 1
      mr2 -q --skip-root-check config:set web/secure/use_in_adminhtml 1
      mr2 -q --skip-root-check config:set web/secure/use_in_frontend 1
      mr2 -q --skip-root-check config:set web/cookie/cookie_lifetime 604800
      mr2 -q --skip-root-check config:set admin/security/session_lifetime 604800
      mr2 -q --skip-root-check config:set admin/security/password_is_forced 0
      
      mr2 -q --skip-root-check setup:config:set --no-interaction --http-cache-hosts=127.0.0.1:6081
      mr2 -q --skip-root-check config:set system/full_page_cache/caching_application 2
      mr2 -q --skip-root-check config:set system/full_page_cache/ttl 604800
      
      #{additional_configurations}
            
      mr2 -q --skip-root-check cache:flush
      
      echo '==> Compiling DI and generating static content'
      rm -rf var/di/ var/generation/
      # Magento 2.0.x required usage of multi-tenant compiler (see here for details: http://bit.ly/21eMPtt).
      # Magento 2.1 dropped support for the multi-tenant compiler, so we must use the normal compiler.
      if [ `bin/magento setup:di:compile-multi-tenant --help &> /dev/null; echo $?` -eq 0 ]; then
          bin/magento setup:di:compile-multi-tenant -q
      else
          bin/magento setup:di:compile -q
      fi
      [ ! -f pub/static/deployed_version.txt ] && touch pub/static/deployed_version.txt
      bin/magento setup:static-content:deploy --jobs 1 -q
      # set environment variable so it exists during the next execution of static-content:deploy
      export https=on
      bin/magento setup:static-content:deploy -q --jobs 1 \
          --no-javascript --no-css --no-less --no-images --no-fonts --no-html --no-misc --no-html-minify
      bin/magento cache:flush -q
      
      echo 'Setting file permissions and ownership'
      
      find $INSTALL_DIR -type d -exec chmod 770 {} +
      find $INSTALL_DIR -type f -exec chmod 660 {} +
      
      chmod -R g+s $INSTALL_DIR
      chown -R www-data:www-data $INSTALL_DIR
      
      chmod +x $INSTALL_DIR/bin/magento
      
      echo 'Linking public directory into webroot'
      mkdir -p $(dirname /var/www/html/#{path})
      ln -s $INSTALL_DIR/pub /var/www/html/#{path}
      
      display_run_time $start_time
    "
  end
end

def install_magento1 (node, host: nil, path: nil, database: nil, version_name: nil, sampledata: true)
  host = host + '.' + CLOUD_DOMAIN
  flag_sd = sampledata ? ' --installSampleData ' : nil
  
  node.vm.provision :shell do |conf|
    conf.name = "install_magento1:#{host}/#{path}"
    conf.inline = "
      set -e
      
      cd #{VAGRANT_DIR}
      source ./scripts/lib/utils.sh
      
      start_time=$(capture_nanotime)
      INSTALL_DIR=/var/www/magento1/#{path}
      
      echo 'Running n98-magerun: install'
      mr1 install -n -q --skip-root-check --magentoVersionByName #{version_name} --installationFolder $INSTALL_DIR \
          --dbHost localhost --dbUser root --dbName #{database} #{flag_sd} --baseUrl http://#{host}/#{path}
      
      echo 'Initializing software configuration'
      
      cd $INSTALL_DIR
      mr1 -q --skip-root-check config:set web/secure/base_url https://#{host}/#{path}/
      mr1 -q --skip-root-check config:set web/secure/use_in_frontend 1
      mr1 -q --skip-root-check config:set web/secure/use_in_adminhtml 1
      mr1 -q --skip-root-check cache:flush
      
      echo 'Setting file permissions and ownership'
      
      find $INSTALL_DIR -type d -exec chmod 770 {} +
      find $INSTALL_DIR -type f -exec chmod 660 {} +
      
      chmod -R g+s $INSTALL_DIR
      chown -R www-data:www-data $INSTALL_DIR
      
      chmod +x $INSTALL_DIR/cron.sh
      
      echo 'Linking public directory into webroot'
      mkdir -p $(dirname /var/www/html/#{path})
      ln -s $INSTALL_DIR /var/www/html/#{path}
      
      display_run_time $start_time
    "
  end
end
