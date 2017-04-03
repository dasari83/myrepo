#
# Cookbook Name:: bh_nginx
# Recipe:: default
#
#
# Tested under Ubuntu 12.04
# with Nginx 1.4.4

if node['bh_nginx'] == nil  || node['bh_nginx']['version'] == nil
  vers = "1.4.4-1~precise"
else
  vers = node['bh_nginx']['version']
end

execute 'apt-get-update' do
  command 'apt-get update'
end

package "nginx" do
  action :install
  options "-y --force-yes"
  version "#{vers}"
end
