require 'puppet/provider/parsedfile'

conf = "/etc/apt/sources.list"

Puppet::Type.type(:apt_source).provide(:parsed,
    :parent => Puppet::Provider::ParsedFile,
    :default_target => conf,
    :filetype => :flat
) do
    text_line :comment, :match => /^#/
    text_line :blank, :match => /^\s*$/
    record_line :parsed, :fields => %w{type url suite component},
        :optional => %w{component}
    
end


