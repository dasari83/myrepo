#
# Cookbook Name:: bh_maven
# Recipe:: default
#
#
#

include_recipe "bh_jdk::default"

vers = node[:bh_maven][:version]

package "maven" do 
  action :install
  version "#{vers}"
  options "-y --force-yes"
end

