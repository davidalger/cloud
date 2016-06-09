# Vagrant Cloud

1.0.1
==========

* Fixed bug preventing composer from using a cache inside www-data shell user

1.0.0
==========

* Changed web stack to nginx -> varnish -> nginx -> php-fpm setup.
* Changed default version of PHP to PHP 7.0 (formerly PHP 5.6).
* Added www-data web user for php-fpm service general SSH access.
* Updated SSH configuration to better secure provisioned servers.
    * Access requires user be a member of sshusers group.
    * Access requires use of public-key authentication.
* Removed all dependencies on the DevEnv GitHub project for a simpler provisioning process.
* Added 2nd sandbox node for dev purposes.
* Removed add_knonw_hosts include script (any nodes using this will need configure.sh updated).
* Added letsencrypt ssl setup so certbot is ready and available to use generating ssl certs.
* Added informational message with ip and hostname info to print on each reload.

0.2.1
==========

* Fixed bug preventing the install_magento2 provisioner from installing at domain root.
* Fixed broken default config file.

0.2.0
==========

* Added support for using Rackspace Cloud provider.
* Upgraded to use latest work from the DevEnv dependency.
* Removed the manager node for the sake of simplicity and a lower security risk surface.
* Other misc enhancements.

0.1.0
==========

* Initial release with support for Digital Ocean provider and using an nginx -> varnish -> apache + mod_php web stack.
