
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
    @name ||= new_resource.name
end

def mock?
    @mock ||= new_resource.mock
end

def mock_env
    Fog.mock!
    conn = Fog::DNS.new(aws)
    conn.create_hosted_zone(name).body['HostedZone']['Id']
    conn
end

def route53
    require 'fog/aws/dns'
    require 'nokogiri'

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

def zone_name
    @zone_name ||= begin
        return new_resource.name + '.' if new_resource.name !~ /\.$/
        new_resource.name
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

def load_current_resource    
    @current_resource ||= route53.zones.all().find { |z| z.domain == zone_name }
end

action :create do
    require 'fog/aws/dns'
    require 'nokogiri'

    if ! @current_resource.nil?
        Chef::Log.debug "Zone #{name} already exists - nothing to do."
    else
        begin
            converge_by("Create zone #{name}") do
                route53.zones.create(:domain => name)
            end
        rescue Excon::Errors::BadRequest => e
            Chef::Log.error Nokogiri::XML( e.response.body ).xpath( "//xmlns:Message" ).text
        end
    end
end

action :delete do
    require 'fog/aws/dns'
    require 'nokogiri'

    if @current_resource.nil?
        Chef::Log.debug "Zone #{name} does not exist - nothing to do."
    else
        begin
            converge_by("Delete zone #{name}") do
                route53.zones.destroy(zone_id)
            end
        rescue Excon::Errors::BadRequest => e
            Chef::Log.error Nokogiri::XML( e.response.body ).xpath( "//xmlns:Message" ).text
        end
    end
end
