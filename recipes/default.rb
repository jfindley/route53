#
# Cookbook Name:: route53
# Recipe:: default
#
# Copyright 2014, Copyright 2012, Digital Window Ltd
#
# All rights reserved - Do Not Redistribute
#

chef_gem "fog" do
    version "1.26.0"
end
chef_gem "nokogiri"
