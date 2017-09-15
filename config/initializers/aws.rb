Aws.config[:region] = 'us-east-1'
Aws.config[:credentials] = if Rails.env.development?
                             Aws::SharedCredentials.new
                           else
                             Aws::InstanceProfileCredentials.new
                           end
