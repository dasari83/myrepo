#
# Cookbook Name:: bh_jdk
# Recipe:: default
#

#
 
log "---------- Started bh_jdk::default recipe ----------"
vers = node['bh_jdk']['version'] if node['bh_jdk'] != nil
if vers.nil? || vers !~ /\w+/i
  vers = '1.7.0u25'
end
#Support for older jdk debian packages
# version = "jdk1.6.0u21"
if vers.include?('jdk')
  tmp=vers.split(%r{\s*k}) # ["jd", "1.6.0u21"] 
  vers = tmp[1]
end

execute 'apt-get-update' do
  command 'apt-get update'
end

package 'jdk' do
  action :install
  version "#{vers}"
  options "-y --force-yes"
end

link "/opt/java" do
  to "/usr/java/default" 
  action :create
end

log "---------- Finished bh_jdk::default recipe ----------"
