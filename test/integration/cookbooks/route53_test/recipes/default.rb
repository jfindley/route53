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
    name "test.com"
    aws_access_key_id node[:route53][:aws_access_key_id]
    aws_secret_access_key node[:route53][:aws_secret_access_key]
end

route53_record "create_record" do
    name "rec1.test.com"
    type "A"
    value [ "1.2.3.4", "7.8.9.1" ]
    zone "test.com"
    ttl 60
    aws_access_key_id node[:route53][:aws_access_key_id]
    aws_secret_access_key node[:route53][:aws_secret_access_key]
end

route53_record "create_healthcheck_record" do
    name "rec2.test.com"
    type "A"
    value "1.2.3.5"
    zone "test.com"
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
    name "rec2.test.com"
    type "A"
    value "1.2.3.8"
    zone "test.com"
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
