module Puppet
    newtype(:mysqld_param) do
        @doc = "Manages parameters of mysqld set in /etc/mysql/my.cnf"
        
        ensurable

        newparam(:name) do
            desc "The name of the parameter."

            isnamevar
        end

        newstate(:target) do
            desc "The file in which to store the parameter"

            defaultto { if @parent.class.defaultprovider.ancestors.include?(Puppet::Provider::ParsedFile)
                    @parent.class.defaultprovider.default_target
                else
                    nil
                end
            }
        end

        autorequire(:package) do
                "mysql-server"
        end

        newstate(:value) do
            desc "The value to set."
        end

    end

end


