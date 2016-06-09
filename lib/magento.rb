##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

def install_magento2 (node, host: nil, path: nil, database: nil, enterprise: false, sampledata: true,
      admin_pass: nil, admin_user: 'admin')
    
  host = host + '.' + CLOUD_DOMAIN
  flag_ee = enterprise ? ' -e ' : nil
  flag_sd = sampledata ? ' -d ' : nil
  
  node.vm.provision :shell do |conf|
    conf.name = "install_magento2:#{host}/#{path}"
    
    opt_urlpath = ''
    if path
      opt_urlpath = "--urlpath=#{path}"
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
      m2setup.sh #{flag_sd} #{flag_ee} --hostname=#{host} #{opt_urlpath} --admin-user=#{admin_user}
      ln -s $INSTALL_DIR/pub $INSTALL_DIR/pub/pub     # todo: remove temp fix when GH Issue #2711 is resolved
      
      echo 'Initializing software configuration'
      
      cd $INSTALL_DIR
      mr2 -q --skip-root-check setup:config:set --no-interaction --http-cache-hosts=127.0.0.1:6081
      mr2 -q --skip-root-check config:set system/full_page_cache/caching_application 2
      mr2 -q --skip-root-check config:set system/full_page_cache/ttl 604800
      mr2 -q --skip-root-check config:set system/full_page_cache/varnish/access_list localhost
      mr2 -q --skip-root-check config:set system/full_page_cache/varnish/backend_host localhost
      mr2 -q --skip-root-check config:set system/full_page_cache/varnish/backend_port 8080
      mr2 -q --skip-root-check cache:flush
      
      echo 'Setting file permissions and ownership'
      
      find $INSTALL_DIR -type d -exec chmod 770 {} +
      find $INSTALL_DIR -type f -exec chmod 660 {} +
      
      chmod -R g+s $INSTALL_DIR
      chown -R apache:nginx $INSTALL_DIR
      
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
      
      echo 'Fixing sample data CMS permissions bug'
      mr1 --skip-root-check db:query \"INSERT INTO permission_block (block_name, is_allowed) VALUES ('cms/block', 'is_allowed')\"

      echo 'Setting file permissions and ownership'
      
      find $INSTALL_DIR -type d -exec chmod 770 {} +
      find $INSTALL_DIR -type f -exec chmod 660 {} +
      
      chmod -R g+s $INSTALL_DIR
      chown -R apache:nginx $INSTALL_DIR
      
      chmod +x $INSTALL_DIR/cron.sh
      
      echo 'Linking public directory into webroot'
      mkdir -p $(dirname /var/www/html/#{path})
      ln -s $INSTALL_DIR /var/www/html/#{path}
      
      display_run_time $start_time
    "
  end
end
