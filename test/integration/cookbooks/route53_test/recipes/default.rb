#
# Cookbook Name:: route53_test
# Recipe:: default
#
# Copyright 2014, Copyright 2012, Digital Window Ltd
#
# All rights reserved - Do Not Redistribute
#

include_recipe "route53"

# Enable this for fog debugging
# ENV['EXCON_DEBUG']="true"
# ENV['DEBUG']="true"

chef_gem "fog"


route53_zone "create_zone" do
    name "heisenberg.com"
    aws_access_key_id node[:route53][:aws_access_key_id]
    aws_secret_access_key node[:route53][:aws_secret_access_key]
end

route53_record "create_record" do
    name "pinkman.heisenberg.com"
    type "A"
    value [ "1.2.3.4" ]
    zone "heisenberg.com"
    ttl 60
    aws_access_key_id node[:route53][:aws_access_key_id]
    aws_secret_access_key node[:route53][:aws_secret_access_key]
end

route53_record "create_healthcheck_record" do
    name "gus.heisenberg.com"
    type "A"
    value "1.2.3.5"
    zone "heisenberg.com"
    weight 50
    health_check true
    health_check_type "http"
    health_check_ip "1.1.1.1"
    health_check_port 80
    health_check_path "/"
    health_check_interval 30
    health_check_threshold 5
    set_id "los_pollos_1"
    aws_access_key_id node[:route53][:aws_access_key_id]
    aws_secret_access_key node[:route53][:aws_secret_access_key]
end

route53_record "create_second_healthcheck_record" do
    name "gus.heisenberg.com"
    type "A"
    value "1.2.3.8"
    zone "heisenberg.com"
    weight 25
    health_check true
    health_check_type "http"
    health_check_ip "1.1.1.2"
    health_check_port 80
    health_check_path "/"
    health_check_interval 30
    health_check_threshold 5
    set_id "los_pollos_2"
    aws_access_key_id node[:route53][:aws_access_key_id]
    aws_secret_access_key node[:route53][:aws_secret_access_key]
end
