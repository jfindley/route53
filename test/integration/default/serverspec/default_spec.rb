require 'spec_helper'

def fog_command(command)
    @fog_command = 'fog -c .fog_creds <<< \'r53 = Fog::DNS.new({ :provider => "AWS" }); ' + command + '\''
end

describe command('/opt/chef/embedded/bin/gem list') do
    its(:stdout) { should match /fog/ }
end

describe command('/opt/chef/embedded/bin/gem list') do
    its(:stdout) { should match /nokogiri/ }
end

describe command('echo -e "default:\n  aws_access_key_id: AKIAJEQIXBOUBLI6ULZQ\n  aws_secret_access_key: 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\n" > .fog_creds') do
    its(:exit_status) { should eq 0 }
end

describe command(fog_command('r53.zones.all()')) do
    its(:stdout) { should match /heisenberg.com./ }
    its(:exit_status) { should eq 0 }
end

describe command(fog_command('r53.zones.all().find {|z| z.domain == "heisenberg.com."}.records.all()')) do
    its(:stdout) { should match /pinkman.heisenberg.com./ }
    its(:exit_status) { should eq 0 }
end

describe command(fog_command('r53.list_health_checks.body')) do
    its(:stdout) { should match /1.1.1.1/ }
    its(:exit_status) { should eq 0 }
end

describe command(fog_command('r53.zones.all().find {|z| z.domain == "heisenberg.com."}.records.get("gus.heisenberg.com.", "A", "los_pollos_1")')) do
    its(:stdout) { should match /1.2.3.5/ }
    its(:exit_status) { should eq 0 }
end

describe command(fog_command('r53.zones.all().find {|z| z.domain == "heisenberg.com."}.records.get("gus.heisenberg.com.", "A", "los_pollos_2")')) do
    its(:stdout) { should match /1.2.3.8/ }
    its(:exit_status) { should eq 0 }
end


# Check that we can delete them all correctly.  This is mostly for cleanup purposes.

describe command(fog_command('r53.delete_health_check(r53.list_health_checks.body["HealthChecks"][0]["Id"])')) do
    its(:stdout) { should match /@status=200/ }
    its(:exit_status) { should eq 0 }
end

describe command(fog_command('r53.zones.all().find {|z| z.domain == "heisenberg.com."}.records.get("pinkman.heisenberg.com.", "A").destroy')) do
    its(:stdout) { should match /true/ }
    its(:exit_status) { should eq 0 }
end

describe command(fog_command('r53.zones.all().find {|z| z.domain == "heisenberg.com."}.records.get("gus.heisenberg.com.", "A", "los_pollos_1").destroy')) do
    its(:stdout) { should match /true/ }
    its(:exit_status) { should eq 0 }
end

describe command(fog_command('r53.zones.all().find {|z| z.domain == "heisenberg.com."}.records.get("gus.heisenberg.com.", "A", "los_pollos_2").destroy')) do
    its(:stdout) { should match /true/ }
    its(:exit_status) { should eq 0 }
end

describe command(fog_command('r53.zones.all().find {|z| z.domain == "heisenberg.com."}.destroy')) do
    its(:stdout) { should match /true/ }
    its(:exit_status) { should eq 0 }
end
