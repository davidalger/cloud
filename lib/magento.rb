##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

def install_magento2 node, host: nil, path: nil, database: nil, enterprise: false, sampledata: true
  host = host + '.' + CLOUD_DOMAIN
  flag_ee = enterprise ? ' -e ' : nil
  flag_sd = sampledata ? ' -d ' : nil
  
  node.vm.provision :shell do |conf|
    conf.name = "install_magento2:#{host}/#{path}"
    conf.inline = "
      set -e
      
      cd #{VAGRANT_DIR}
      source ./scripts/lib/utils.sh
      
      start_time=$(capture_nanotime)
      
      export DB_HOST=localhost
      export DB_NAME=#{database}
      export INSTALL_DIR=/var/www/magento2/#{path}
      
      echo 'Running subscript: m2setup.sh'
      m2setup.sh #{flag_sd} #{flag_ee} --hostname=#{host} --urlpath=#{path}
      ln -s $INSTALL_DIR/pub $INSTALL_DIR/pub/pub     # todo: remove temp fix when GH Issue #2711 is resolved
      
      echo 'Initializing software configuration'
      
      cd $INSTALL_DIR
      mr2 -q config:set system/full_page_cache/caching_application 2
      mr2 -q config:set system/full_page_cache/ttl 604800
      mr2 -q config:set system/full_page_cache/varnish/access_list localhost
      mr2 -q config:set system/full_page_cache/varnish/backend_host localhost
      mr2 -q config:set system/full_page_cache/varnish/backend_port 8080
      mr2 -q cache:flush
      
      echo 'Setting file permissions and ownership'
      
      find $INSTALL_DIR -type d -exec chmod 770 {} +
      find $INSTALL_DIR -type f -exec chmod 660 {} +
      
      chmod -R g+s $INSTALL_DIR
      chown -R apache:apache $INSTALL_DIR
      
      chmod +x $INSTALL_DIR/bin/magento
      
      echo 'Linking public directory into webroot'
      mkdir -p $(dirname /var/www/html/#{path})
      ln -s $INSTALL_DIR/pub /var/www/html/#{path}
      
      display_run_time $start_time
    "
  end
end

def install_magento1 node, host: nil, path: nil, database: nil, enterprise: false, sampledata: true
  host = host + '.' + CLOUD_DOMAIN
  flag_ee = enterprise ? ' -e ' : nil
  flag_sd = sampledata ? ' -d ' : nil
  
  return # todo: remove after implimenting m1setup.sh script
  
  node.vm.provision :shell do |conf|
    conf.name = "install_magento1"
    conf.inline = "
      set -e
      
      cd $VAGRANT_DIR
      source ./scripts/lib/utils.sh
      
      start_time=$(capture_nanotime)
      
      export DB_HOST=localhost
      export DB_NAME=#{database}
      export INSTALL_DIR=/var/www/html/#{path}
      
      m1setup.sh #{flag_sd} #{flag_ee} --hostname=#{host} --urlpath=#{path}
      
      find $INSTALL_DIR -type d -exec chmod 770 {} +
      find $INSTALL_DIR -type f -exec chmod 660 {} +
      
      chmod -R g+s $INSTALL_DIR
      chown -R apache:apache $INSTALL_DIR
      
      chmod +x $INSTALL_DIR/cron.sh
      
      display_run_time $start_time
    "
  end
end
