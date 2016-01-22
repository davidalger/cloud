##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

unless defined? CLOUD_DOMAIN
  raise "Missing configuration for CLOUD_DOMAIN. This must be set in config.rb"
end

unless defined? CLOUD_CONFIG
  raise "Missing configuration for CLOUD_CONFIG. This must be set in config.rb and should be an ssh git repo url"
end

unless defined? CONF_DO_KEY_PATH
  CONF_DO_KEY_PATH = '~/.ssh/id_rsa'
end

unless defined? CONF_DO_KEY_NAME
  CONF_DO_KEY_NAME = 'Vagrant'
end

unless defined? CONF_DO_TOKEN
  raise "Missing configuration for CONF_DO_TOKEN. This must be set in config.rb"
end

unless defined? CONF_DO_IMAGE
  CONF_DO_IMAGE = 'centos-6-5-x64' # this is really CentOS 6.7 x64
end

unless defined? CONF_DO_REGION
  CONF_DO_REGION = 'nyc2'
end

unless defined? CONF_DO_SIZE
  CONF_DO_SIZE = '2gb'
end

unless defined? CONF_DO_BOX_NAME
  CONF_DO_BOX_NAME = 'digital_ocean'
end

unless defined? CONF_DO_BOX_URL
  CONF_DO_BOX_URL = 'https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'
end
