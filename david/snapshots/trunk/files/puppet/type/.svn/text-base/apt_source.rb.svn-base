module Puppet
    newtype(:apt_source) do
        @doc = "Manages /etc/apt/sources.list"
        
        ensurable

        newparam(:name) do
            desc "The name of this entry. Actually unused."

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

        newstate(:type) do
            desc "deb or deb-src"
        end

        newstate(:url) do
            desc "The base URL of the Debian mirror."
        end

        newstate(:suite) do
            desc "which suite to load, e.g. unstable or etch"
        end

        newstate(:component) do
            desc "which components to load. Typically main"
        end

    end

end


