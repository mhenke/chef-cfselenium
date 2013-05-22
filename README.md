Description
===========

Installs the CFSelenium.

Attributes
==========

* `node['CFSelenium']['install_path']` (Default is /vagrant/wwwroot)
* `node['CFSelenium']['owner']` (Default is `nil` which will result in owner being set to `node['cf10']['installer']['runtimeuser']`)
* `node['CFSelenium']['group']` (Default is bin)
* `node['CFSelenium']['download']['url']` (Default is https://github.com/boughtonp/CFSelenium/archive/master.zip)
* `node['CFSelenium']['create_apache_alias']` (Default is false)

Usage
=====

On ColdFusion server nodes:

    include_recipe "CFSelenium"