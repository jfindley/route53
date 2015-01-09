actions :create, :delete

default_action :create

attribute :name,                  :kind_of => String
attribute :aws_access_key_id,     :kind_of => String
attribute :aws_secret_access_key, :kind_of => String
attribute :aws_session_token,     :kind_of => String
attribute :mock,                  kind_of: [TrueClass, FalseClass], default: false
