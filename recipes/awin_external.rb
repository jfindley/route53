#
# Cookbook Name:: route53
# Recipe:: awin_external
#
# Copyright 2014, Copyright 2012, Digital Window Ltd
#
# All rights reserved - Do Not Redistribute
#
# include_recipe "chef-encryption"
# include_recipe "route53"

aws_creds = Chef::EncryptedDataBagItem.load("api-creds", "r53_api")

records_by_ip = {}

node['route53']['zones'].each do |zone|
    dns_recs = search(:dns,"zone:#{zone}")

    dns_recs.each do |bag|
        def_ttl = bag['default_ttl']

        bag['addresses'].each do |name, rectypes|

            recname = ""
            if name == "@"
                recname = zone
            else
                recname = "#{name}.#{zone}"
            end

            rectypes.each do |rectype, record|

                content = []
                ttl = 0

                record.each do |rec|

                    # Update Assets
                    if rectype == "A"
                        if records_by_ip.has_key?(rec['content'])
                            records_by_ip[rec['content']] += ", #{recname}"
                        else
                            records_by_ip[rec['content']] = recname
                        end
                    end

                    # Always use the lowest TTL
                    if rec.has_key?('ttl')
                        if rec['ttl'] < ttl or ttl == 0
                            ttl = rec['ttl']
                        end
                    end

                    content += [ rec['content'] ]

                end

                if ttl == 0
                    ttl = def_ttl
                end

                route53_record "manage #{recname}" do
                    name                    recname
                    value                   content
                    type                    rectype
                    ttl                     ttl
                    zone_id                 node['route53']['zone-id'][zone]
                    aws_access_key_id       aws_creds['aws_access_key_id']
                    aws_secret_access_key   aws_creds['aws_secret_access_key']
                    overwrite true
                    action :create
                end

            end

        end

    end
    
end

records_by_ip.each do |ip, name|
    awinAssetsManagement_ipv4 name do
        address ip
    end
end
