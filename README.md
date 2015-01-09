Description
===========

Manages Amazon Route53 (DNS) service.
Includes support for healthchecks, failover zones and other advanced features.

Requirements
===========

An AWS account with an access key.

Usage
=====

```ruby
route53_zone "create a zone" do
    name "test.com"
    aws_access_key_id # AWS creds
    aws_secret_access_key # AWS creds
end


route53_record "create a simple record" do
    name "foo.test.com"
    type "A"
    value "1.2.3.4"
    zone "test.com"
    ttl 60
    aws_access_key_id # AWS creds
    aws_secret_access_key # AWS creds
end

route53_record "create a round-robin record" do
    name "bar.test.com"
    type "A"
    value [ "1.2.3.4", "2.3.4.5" ]
    zone "test.com"
    ttl 60
    aws_access_key_id # AWS creds
    aws_secret_access_key # AWS creds
end

route53_record "create a healthcheck record" do
    name "baz.test.com"
    type "A"
    value "1.2.3.5"
    zone "test.com"
    weight 50
    health_check true
    health_check_type "http"
    health_check_ip "1.2.3.5"
    health_check_port 80
    health_check_path "/"
    health_check_interval 30
    health_check_threshold 5
    set_id "test_1"
    aws_access_key_id # AWS creds
    aws_secret_access_key # AWS creds
end

route53_record "create a second healthcheck record" do
    name "baz.test.com"
    type "A"
    value "1.2.3.6"
    zone "test.com"
    weight 25
    health_check true
    health_check_type "http"
    health_check_ip "1.2.3.6"
    health_check_port 80
    health_check_path "/"
    health_check_interval 30
    health_check_threshold 5
    set_id "test_2"
    aws_access_key_id # AWS creds
    aws_secret_access_key # AWS creds
end

```

Testing
=======

```ruby
bundle install

librarian-chef install
```

Edit .kitchen.yml and update attribute values.

```ruby
kitchen converge
```

ChefSpec Matcher
================

This Cookbook includes a [Custom Matcher](http://rubydoc.info/github/sethvargo/chefspec#Testing_LWRPs)
for testing the **route53_record** LWRP with [ChefSpec](http://rubydoc.info/github/sethvargo/chefspec#Testing_LWRPs).

To utilize this Custom Matcher use the following test your spec:

```ruby
expect(chef_run).to create_route53_zone('example.com')
expect(chef_run).to create_route53_record('test.example.com')
```
