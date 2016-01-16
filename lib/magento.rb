##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

@composer_auth_verified = false

def mage2_install node, host: nil, db_name: nil, db_host: 'localhost', db_user: 'root', db_pass: nil
  verify_composer_auth_file
  
  # build flag for db password if given
  if db_pass
    db_pass = '--db-pass=' + db_pass
  end
  
  if not db_name
    raise 'db_name is a required argument'
  end
  
  host = host + '.' + CLOUD_DOMAIN
  
  node.vm.provision :shell do |conf|
    conf.name = 'mage2_install'
    conf.inline = "
      set -x
      
      export SITES_DIR=/var/www
      export DB_HOST=localhost
      
      m2setup.sh -d -e --hostname=m2.demo
      
      rmdir /var/www/html
      ln -s /var/www/m2.demo/pub /var/www/html
      
      find /var/www/m2.demo -type d -exec chmod 770 {} \;
      find /var/www/m2.demo -type f -exec chmod 660 {} \;
      
      chmod -R g+s /var/www/m2.demo
      chown -R apache:apache /var/www/m2.demo
      
      chmod +x /var/www/m2.demo/bin/magento
    "
  end
end

# todo: need to fix this
def verify_composer_auth_file
  return true
  
  if @composer_auth_verified
    return true
  end
  
  if File.exist? BASE_DIR + '/etc/composer/auth.json'
    @composer_auth_verified = true
  else
    raise 'Error: The configuration requires a composer auth file be present at ' + BASE_DIR + '/etc/composer/auth.json'
  end
end
