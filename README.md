# Vagrant Cloud

A vagrant based environment for easily defining and spinning up many stage and/or demo environments. The stack provisioned by the scripts is an nginx / varnish / nginx sandwich with php-fpm as the backend.

Currently supports Virtual Box, Digital Ocean and Rackspace Cloud providers.

SSH access to machines is restricted to public-key authorization only. There is a www-data user created by the provisioning scripts with SSH access enabled for the keys authorized for the vagrant/root user. This user is the web user and does not have sudoers privilegies.
