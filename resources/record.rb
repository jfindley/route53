actions :create, :delete

default_action :create

attribute :name,                  :kind_of => String
attribute :value,                 :kind_of => [ String, Array ]
attribute :type,                  :kind_of => String
attribute :ttl,                   :kind_of => Fixnum, :default => 3600
attribute :zone,                  :kind_of => String
attribute :aws_access_key_id,     :kind_of => String
attribute :aws_secret_access_key, :kind_of => String
attribute :aws_session_token,     :kind_of => String
attribute :health_check,          :kind_of => [TrueClass, FalseClass], :default => false
attribute :health_check_ip,       :kind_of => String
attribute :health_check_port,     :kind_of => Fixnum
attribute :health_check_type,     :kind_of => String
attribute :health_check_path,     :kind_of => String
attribute :health_check_search_string,     :kind_of => String
attribute :health_check_interval,          :kind_of => Fixnum
attribute :health_check_threshold,         :kind_of => Fixnum
attribute :set_id,            :kind_of => String
attribute :weight,                :kind_of => Fixnum
attribute :mock,                  kind_of: [TrueClass, FalseClass], default: false
