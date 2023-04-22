require 'puppet/provider/parsedfile'

conf = "/etc/mysql/my.cnf"

Puppet::Type.type(:mysqld_param).provide(:parsed,
    :parent => Puppet::Provider::ParsedFile,
    :default_target => conf,
    :filetype => :flat
) do
    text_line :comment, :match => /^#/
    text_line :blank, :match => /^\s*$/
    text_line :section, :match => /^\[/
    text_line :include, :match => /^!/
    record_line :parsed, :fields => %w{name value},
        :separator => /\s*=\s*|#.*|\s*$/, :joiner => ' = ',
        :optional => %w{value}
    
end

