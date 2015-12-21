##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

def mage2_install (node, host: nil, db_name: nil, db_host: 'localhost', db_user: 'root', db_pass: nil)
  
  # build flag for db password if given
  if db_pass
    db_pass = '--db-pass=' + db_pass
  end
  
  if not db_name
    raise 'db_name is a required argument'
  end
  
  node.vm.provision :shell do |conf|
    conf.name = 'mage2_install'
    conf.inline = "
      set -x
      
      composer create-project --prefer-dist -q --repository-url=https://repo.magento.com/ \
          magento/project-community-edition /var/www/magento2
      
      cd /var/www/magento2
      chmod +x bin/magento
      bin/magento sampledata:deploy -q
      composer update --prefer-dist -q
      
      mysql -e 'create database #{db_name}'
      bin/magento setup:install -q --base-url=http://#{host} --backend-frontname=backend \
              --admin-user=admin --admin-firstname=Admin --admin-lastname=Admin \
              --admin-email=user@example.com --admin-password=A123456 \
              --db-host=#{db_host} --db-user=#{db_user} #{db_pass} --db-name=#{db_name}
      
      rmdir /var/www/html
      ln -s /var/www/magento2/pub /var/www/html
      
      bin/magento deploy:mode:set production --skip-compilation -q
      rm -rf var/di/ var/generation/
      bin/magento setup:di:compile-multi-tenant -q
      bin/magento setup:static-content:deploy -q
      bin/magento cache:flush -q
      
      chown -R apache:apache /var/www/magento2
      chmod -R 777 /var/www/magento2
      chmod -R g+s /var/www/magento2
    "
  end
end
