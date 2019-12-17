#### Table of Contents

1. [Description](#description)
1. [Usage](#usage)
1. [Reference](#reference)
1. [Types](#types)
1. [Feedback](#feedback)
1. [Development](#development)

## Description

Enable management of many things without writing any puppet code!  This module
supports ANY resource type from ANY module and by default includes ALL the
native types supported by the puppet agent, the
['file_line' type](https://forge.puppet.com/puppetlabs/stdlib/reference#file_line)
from puppetlabs/stdlib, and the local defined type ['binary'](#types).  This is
an evolution of my [basic](https://forge.puppet.com/southalc/basic) module, but
released as a new module due to the different approach to handling type data
via parameters.

The module can also be extended to support new types by simply adding the type
name(s) to the `types` parameter as an array.  Of course, the module providing
the type must also be deployed in the environment or you'll get an evaluation
error for an unknown resource type.

## Usage

To get started, just define resources in hiera.  Use `types::<type_name>` where
`type_name` can be ANY type from ANY module present in the environment.  See the
examples for help getting started and the
[type reference](https://puppet.com/docs/puppet/6.10/type.html) for details on
the native puppet types.

Many puppet modules only perform simple tasks like installing packages, writing
configuration files, and starting services.  Since this module can do all these
things and more, it's possible to replace the functionality of MANY modules by
using this one and defining appropriate resources in hiera.  In addition,
types that are provided by other modules can easily be used by this module,
allowing those resources to be managed easily from hiera and without writing
any puppet code.

Use [relationship metaparameters](https://puppet.com/docs/puppet/6.10/lang_relationships.html)
in your hiera data to order resource dependencies.  A typical application will
have 'package', 'file', and 'service' resources, and the logical order would
have the file resource(s) 'require' the package, and either have the service
resource 'subscribe' to the file resource(s) or have the file resource(s)
'notify' the corresponding service.

### Examples
This deployment of the name service caching daemon demonstrates installation of
a package, configuration of a file, and refreshes the service when the managed
configuration file chagnes.
```
types::package:
  nscd:
    ensure: 'installed'

types::file:
  '/etc/nscd.conf':
    ensure: 'file'
    owner: 'root'
    group: 'root'
    mode: '600'
    require:
      - 'Package[nscd]'
    notify:
      - 'Service[nscd]'
    content: |
      ## FILE MANAGED BY PUPPET - LOCAL CHANGES WILL NOT PERSIST
        logfile                /var/log/nscd.log
        server-user            nscd
        debug-level            0
        paranoia               no
        
        enable-cache           hosts           yes
        positive-time-to-live  hosts           3600
        negative-time-to-live  hosts           20
        suggested-size         hosts           211
        check-files            hosts           yes
        persistent             hosts           yes
        shared                 hosts           yes
        max-db-size            hosts           33554432

types::service:
  nscd:
    ensure: 'running'
    enable: true
```
This demonstrates use of an exec resource for reloading iptables when the
subscribed resource file is updated.
```
types::file:
  /etc/sysconfig/iptables:
    ensure: 'file'
    owner: 'root'
    group: 'root'
    mode: '600'
    content: |
      *filter
      :INPUT DROP
      :FORWARD DROP
      :OUTPUT ACCEPT
      -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
      -A INPUT -i lo -j ACCEPT
      -A INPUT -p icmp -j ACCEPT
      -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
      COMMIT

types::exec:
  iptables_restore:
    path: '/sbin:/usr/sbin:/bin:/usr/bin'
    command: 'iptables-restore /etc/sysconfig/iptables'
    subscribe: 'File[/etc/sysconfig/iptables]'
    refreshonly: true
```
This is a more complex example that demonstrates extending the module to include
types provided by the [concat](https://forge.puppet.com/puppetlabs/concat/readme)
module, installing an OpenSSH server, and configuring the `sshd_config` file as
a `concat_file`, with content provided from a `concat_fragment`.  All systems
in the environment could be targeted with this configuration:
```
types::types:
  - 'concat_file'
  - 'concat_fragment'

types::package:
  openssh-server:
    ensure: installed

types::service:
  sshd:
    ensure: 'running'
    enable: true
    require: 'Package[openssh-server]'

types::concat_file:
  /etc/ssh/sshd_config:
    owner: 'root'
    group: 'root'
    mode: '0600'
    ensure_newline: true
    notify: 'Service[sshd]'

types::concat_fragment:
  global_sshd_config:
    target: '/etc/ssh/sshd_config'
    order: '01'
    content: |
      # FILE MANAGED BY PUPPET
      HostKey /etc/ssh/ssh_host_rsa_key
      AuthorizedKeysFile .ssh/authorized_keys
      UsePAM yes
      X11Forwarding yes
      AcceptEnv LANG LC_* LANGUAGE XMODIFIERS
      Subsystem sftp /usr/libexec/openssh/sftp-server
```
The above SSH server configuration can now be extended by adding another
`concat_fragment` resource for systems that require additional settings.  This
would be targeted in the hierarchy against some subset of nodes to extend the
default configuration:
```
types::concat_fragment:
  sensitive_sshd_config:
    target: '/etc/ssh/sshd_config'
    order: '10'
    content: |
      # Only allow login by members of the 'admins' group
      AllowGroups admins
```
## Reference

The module has only 2 parameters: `types` and `merge`.  Default values enable
the types per the above description, and set the
[merge behavior](https://puppet.com/docs/puppet/6.10/hiera_merging.html) to
`deep` with a knockout prefix of `--`.

Data for each enabled type is obtained through an explicit lookup() that defaults
to an empty hash.  This means that unless there are resources defined in hiera
the module won't do anything.

## Types

The defined type 'types::binary' works like the standard 'file' type and uses all
the same attributes, but the 'content' attribute type must be a base64 encoded string.
This is useful for distributing small files that may be security sensitive such
as Kerberos keytabs.

The `types::type` defined type replaces create_resources() by using abstracted
resource types as [documented here.](https://puppet.com/docs/puppet/5.5/lang_resources_advanced.html)
This should be invoked by the resource type being created with a '$hash' parameter
containing the properties of the resource.

For both 'types::binary' and 'types::type', an optional 'defaults' hash may be
passed which could be useful in reducing the amount of data needed when declaring
many resources with similar attributes.

## Feedback

Please use the [project wiki on github](https://github.com/southalc/types/wiki)
for feedback, questions, or to share your creative use of this module.

## Development

This module is under lazy development and is unlikely to get much attention.
That said, it's pretty simple and unlikely to need much upkeep.

