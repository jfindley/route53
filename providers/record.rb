
def whyrun_supported?
    true
end

def aws
    {
    :provider => 'AWS',
    :aws_access_key_id => new_resource.aws_access_key_id,
    :aws_secret_access_key => new_resource.aws_secret_access_key,
    :aws_session_token => new_resource.aws_session_token
    }
end

def name
    @name ||= begin
        return new_resource.name + '.' if new_resource.name !~ /\.$/
        new_resource.name
    end
end

def zone_name
    @zone_name ||= begin
        return new_resource.zone + '.' if new_resource.zone !~ /\.$/
        new_resource.zone
    end
end

def value
    @value ||= Array(new_resource.value)
end

def type
    @type ||= new_resource.type
end

def ttl
    @ttl ||= begin
        ttl = new_resource.ttl.to_s
    end
end

def health_check
    @health_check ||= new_resource.health_check
end

def health_check_ip
    @health_check_ip ||= new_resource.health_check_ip
end

def health_check_port
    @health_check_port ||= new_resource.health_check_port
end

def health_check_type
    @health_check_type ||= if ! new_resource.health_check_type.nil?
        health_check_type = new_resource.health_check_type.upcase
    end
end

def health_check_path
    @health_check_path ||= new_resource.health_check_path
end

def health_check_search_string
    @health_check_search_string ||= new_resource.health_check_search_string
end

def health_check_interval
    @health_check_interval ||= new_resource.health_check_interval
end

def health_check_threshold
    @health_check_threshold ||= new_resource.health_check_threshold
end

def set_id
    @set_id ||= new_resource.set_id
end

def weight
    @weight ||= if ! new_resource.weight.nil?
        weight = new_resource.weight.to_s
    end
end

def mock?
    @mock ||= new_resource.mock
end

def mock_env
    Fog.mock!
    conn = Fog::DNS.new(aws)
    zone_id = conn.create_hosted_zone(name).body['HostedZone']['Id']
    conn.zones.get(zone_id)
end

def route53
    require 'fog/aws/dns'
    require 'nokogiri'

    Excon.defaults[:ssl_verify_peer] = false

    @route53 ||= begin
        if mock?
            @route53 = mock_env
        elsif new_resource.aws_access_key_id && new_resource.aws_secret_access_key
            @route53 = Fog::DNS.new(aws)
        else
            Chef::Log.info "No AWS credentials supplied, going to attempt to use IAM roles instead"
            @route53 = Fog::DNS.new({ :provider => "AWS", :use_iam_profile => true })
        end
    end
end

def zone_id
    @zone_id ||= begin
        if mock?
            @zone_id = '1234'
        else
            @zone_id = route53.zones.all().find { |z| z.domain == zone_name }.id
        end
    end
end

def health_check_list
    health_check_list ||= begin
        list = route53.list_health_checks.body
        if list.has_key?("HealthChecks")
            health_check_list = list["HealthChecks"]
        end
    end
end

def zone
    @zone ||= route53.zones.get(zone_id)
end

def load_current_resource
    @current_resource ||= zone.records.get(name, type, set_id)
end

def current_health_check
    current_health_check ||= health_check_list.find do |check|
        check["HealthCheckConfig"]["IPAddress"] == health_check_ip
        check["HealthCheckConfig"]["Port"] == health_check_port.to_s
        check["HealthCheckConfig"]["Type"] == health_check_type
        check["HealthCheckConfig"]["ResourcePath"] == health_check_path
    end
end

def create_health_check
    Chef::Log.debug "Creating healthcheck for #{health_check_type}://#{health_check_ip}:#{health_check_port}#{health_check_path}"
    options = {:resource_path => health_check_path}

    if ! health_check_interval.nil?
        options["interval"] = health_check_interval
    end

    if ! health_check_threshold.nil?
        options["threshold"] = health_check_threshold
    end

    if type == "HTTP_STR_MATCH" || type == "HTTPS_STR_MATCH"
        options["search_string"] = health_check_search_string
    end

    begin
        route53.create_health_check(health_check_ip, health_check_port, health_check_type, options)
    rescue Excon::Errors::BadRequest => e
        Chef::Log.error Nokogiri::XML( e.response.body ).xpath( "//xmlns:Message" ).text
    end
end

def has_changed
    options = {}

    if current_resource.ttl != ttl
        Chef::Log.debug "Changing TTL for #{name} to #{ttl}"
        options["ttl"] = ttl
    end
    if current_resource.value != value
        Chef::Log.debug "Changing value for #{name} to #{value}"
        options["value"] = value
    end
    if current_resource.weight != weight
        Chef::Log.debug "Changing weight for #{name} to #{weight}"
        options["weight"] = weight
    end

    if health_check

        if current_health_check.nil?

            create_health_check
            options["health_check_id"] = current_health_check["Id"]

        elsif current_resource.health_check_id != current_health_check["Id"]

            options["health_check_id"] = current_health_check["Id"]

        end

        if current_resource.set_identifier != set_id
            Chef::Log.debug "Changing set_id for #{name} to #{set_id}"
            options["set_identifier"] = set_id
        end

    else

        if ! current_health_check.nil?
            Chef::Log.debug "Removing healthcheck from #{name}"
            options["health_check_id"] = nil
        end

        if ! current_resource.set_identifier.nil?
            Chef::Log.debug "Removing set_id from #{name}"
            options["set_identifier"] = nil
        end

    end

    return options
end

def modify_record(options)
    begin
        current_resource.modify(options)
    rescue Excon::Errors::BadRequest => e
        Chef::Log.error Nokogiri::XML( e.response.body ).xpath( "//xmlns:Message" ).text
    end
end

def create_record
    require 'fog/aws/dns'
    require 'nokogiri'

    options = {}

    if health_check

        if current_health_check.nil?
            create_health_check
        end

        options["health_check_id"] = current_health_check["Id"]
        options["set_identifier"] = set_id

    end

    options["name"] = name
    options["type"] = type
    options["ttl"] = ttl
    options["value"] = value
    options["weight"] = weight

    begin
        zone.records.create(options)
    rescue Excon::Errors::BadRequest => e
        Chef::Log.error Nokogiri::XML( e.response.body ).xpath( "//xmlns:Message" ).text
    end

end

action :create do
    require 'fog/aws/dns'
    require 'nokogiri'

    if health_check && ( weight.nil? || set_id.nil? )
        Chef::Log.error "Error: health checks require weight and set_id."
        Chef::Application.fatal!("Invalid health check definition for #{name}")
    else
        if current_resource.nil?
            converge_by("create record #{name}") do
                create_record
            end
        else
            options = has_changed
            if options.length == 0
                Chef::Log.info "Record #{name} is up to date - nothing to do."
            else
                converge_by("update record #{name}") do
                    modify_record
                end
            end
        end
    end

end

action :delete do
    require 'fog/aws/dns'
    require 'nokogiri'

    if !current_resource.nil?
        converge_by("delete record #{name}") do
            begin
                current_resource.destroy
            rescue Excon::Errors::BadRequest => e
                Chef::Log.error Nokogiri::XML( e.response.body ).xpath( "//xmlns:Message" ).text
            end
        end
    else
        Chef::Log.debug 'There is nothing to delete'
    end
end
