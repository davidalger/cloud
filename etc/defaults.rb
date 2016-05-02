##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

########################################
# Environment Configuration

unless defined? CLOUD_DOMAIN
  raise "Missing configuration for CLOUD_DOMAIN. This must be set in config.rb"
end

########################################
# Digital Ocean Configuration

unless defined? CONF_DO_PK_PATH
  CONF_DO_PK_PATH = '~/.ssh/id_rsa'
end

unless defined? CONF_DO_PK_NAME
  CONF_DO_PK_NAME = 'VagrantCloud'
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

########################################
## AWS Configuration

unless defined? CONF_AWS_AMI
  CONF_AWS_AMI = 'ami-8997afe0'
end

unless defined? CONF_AWS_PK_PATH
  CONF_AWS_PK_PATH = '~/.ssh/id_rsa'
end

unless defined? CONF_AWS_PK_NAME
  CONF_AWS_PK_NAME = 'VagrantCloud'
end

########################################
# Rackspace Cloud Configuration
#
# To use RAX provider, you must manually create a CentOS 6 based image which allows sudo without a tty. To do this:
#  1. Spin up a server based on the "CentOS 6 (PVHVM)" image via the Rackspace Cloud UI
#  2. SSH into the box and run the following command:
#     $ sed -i.bk -e 's/^\(Defaults\s\+requiretty\)/# \1/' /etc/sudoers
#  3. Logout of the box and create an image named "CentOS 6 Base Image" via the Rackspace Cloud UI
#

unless defined? CONF_RAX_REGION
  CONF_RAX_REGION = :iad
end

unless defined? CONF_RAX_FLAVOR
  CONF_RAX_FLAVOR = '1 GB Performance'
end

unless defined? CONF_RAX_IMAGE
  CONF_RAX_IMAGE = 'CentOS 6 Base Image'
end

unless defined? CONF_RAX_PK_PATH
  CONF_RAX_PK_PATH = '~/.ssh/id_rsa'
end

unless defined? CONF_RAX_PK_PUB_PATH
  CONF_RAX_PK_PUB_PATH = '~/.ssh/id_rsa.pub'
end
