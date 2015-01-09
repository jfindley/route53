# ChefSpec matcher for route53 Cookbook.
#
# Library:: matchers
# Cookbook Name:: route53



if defined?(ChefSpec)
    def create_route53_record(name)
        ChefSpec::Matchers::ResourceMatcher.new(:route53_record, :create, name)
    end

    def delete_route53_record(name)
        ChefSpec::Matchers::ResourceMatcher.new(:route53_record, :delete, name)
    end

    def create_route53_zone(name)
        ChefSpec::Matchers::ResourceMatcher.new(:route53_zone, :create, name)
    end

    def delete_route53_zone(name)
        ChefSpec::Matchers::ResourceMatcher.new(:route53_zone, :delete, name)
    end

end
