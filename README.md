#### Table of Contents

1. [Description](#description)
1. [Usage](#usage)
1. [Reference](#reference)
1. [Types](#types)
1. [Bolt plan](#bolt)
1. [Feedback](#feedback)
1. [Development](#development)

## Description

Enable management of many things without writing puppet code!  Like many other modules on puppet forge,
this module creates resources from data defined in hiera hashes.  The difference is that this module
supports ALL types (and defined types) from ANY module.  Support for new types is enabled by using the
`types` parameter with an array of the new types.  Of course, when using types from other modules, the
module actually providing the type must be deployed in the environment.

By default, the module implements all the native resource types supported by the puppet agent, the
['file_line' type](https://forge.puppet.com/puppetlabs/stdlib/reference#file_line) from puppetlabs/stdlib,
and the local defined type ['binary'](#types).  

## Usage

To get started, just include the module and define resources in hiera.  Use `types::<type_name>` where
`type_name` can be ANY type or defined type from ANY module present in the environment.  When defining
resources for types not natively supported per the above description, ensure you also define the hiera
array `types::types` with the type names that should be included.  See the examples for a demonstration
that leverages types from other modules, and see the ['types'](#types) notes for how to define default
values for any type.

Many puppet modules only perform simple tasks like installing packages, writing configuration files,
and starting services.  Since this module can do all these things and more, it's possible to replace
the functionality of MANY modules by using this one and defining the resources in hiera.

Use [relationship metaparameters](https://puppet.com/docs/puppet/6.10/lang_relationships.html) in your
hiera data to order resource dependencies.  A typical application will have 'package', 'file', and
'service' resources, and the logical order would have the file resource(s) 'require' the package, and
either have the service resource 'subscribe' to the file resource(s) or have the file resource(s)
'notify' the corresponding service.  See this in the following examples.

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
This example demonstrates adding the types `concat_file` and `concat_fragment` provided by
[concat](https://forge.puppet.com/puppetlabs/concat/readme).  The additional resources will
install an OpenSSH server, configure 'sshd_config' from a `concat_file` resource, and add
content to 'sshd_config' from a `concat_fragment` resource.  This configuration can now be
extended with additional `concat_fragment` resources from elsewhere in hiera.
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
This `concat_fragment` resource will be added to the above configuration using the specified
order.  This could also be used for 'Match' blocks or any other configuration snippet that
shouldn't apply to the entire environment, but are required for some sub-set of nodes in the
hierachy.
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

The module has only 2 parameters: `types` and `merge`.  Default values enable the types per the
above description, and set the [merge behavior](https://puppet.com/docs/puppet/6.10/hiera_merging.html)
to `deep` with a knockout prefix of `--`.

Data for each enabled type is obtained through an explicit lookup() that defaults to an empty hash.
This means that unless there are resources defined in hiera the module won't do anything.

## Types

The defined type 'types::binary' works like the standard 'file' type and uses all the same
attributes, but the 'content' attribute type must be a base64 encoded string. This is useful
for distributing small files that may be security sensitive such as Kerberos keytabs.

The defined type `types::type` replaces create_resources() by using abstracted resource types as
[documented here.](https://puppet.com/docs/puppet/5.5/lang_resources_advanced.html)  This should
be invoked by the resource type being created with a '$hash' parameter containing the properties
of the resource.

For both `types::binary` and `types::type`, a `defaults` parameter is defined as a hash that will
be used for default values.  By default, the module will perform an explicit lookup for
`types::<type>_defaults` for each enabled resource type where a hash is present in hiera, then pass
the value as 'defaults' when calling the respective defined type.  This is useful in reducing the
amount of data needed to define many resources of the same type with similar attributes.  For example,
you could set default attributes for all 'service' types as follows:
```
types::service_defaults:
  ensure: 'running'
  enable: true

types::service:
  service1: {}
  service2: {}
  service3:
    ensure: 'stopped'
    enable: false
```
Note in the above example how the defined services can be set to empty hashes, as the supplied defaults
are adequate to complete the resource definitions.  Values explicitly defined to a service instance
take precedent over the default values.

## Bolt

New with version 0.3.0 of the module is a simple Bolt plan that uses the same hiera driven model
to deliver Puppet automation with no server infrastructure requirements.  The Bolt plan includes
an "apply" block that includes only a hiera lookup for assigned classes.  This enables use of
the types module, or any other for that matter, in hiera.

To get started with the Bolt plan once Bolt is installed, initialize a Bolt project directory to
include this module as follows:
```
bolt project init --modules southalc-types
```
Configure the Bolt [project](https://puppet.com/docs/bolt/latest/bolt_project_reference.html), and
[inventory](https://puppet.com/docs/bolt/latest/bolt_inventory_reference.html) files as needed to manage
the target systems using the transport and authentication as needed.

Create a hiera configuration in the Bolt project to assign classes and define puppet resources.
Consider the following `hiera.yaml` structure.  This design allows granular configuration of
individual nodes, then more general configuration based on the OS name and version.  Use of
variables in Bolt enables assignment of one or more roles, backed by hiera YAML files.  The
Bolt inventory can define variables for individual nodes, groups, or globally.
```
---
version: 5
defaults:
  datadir: data
  data_hash: yaml_data

hierarchy:
  - name: "Puppet Bolt project hierarchy"
    paths:
      - "nodes/%{::fqdn}.yaml"                     # Host specific data has highest priority
      - "virtual/%{virtual}.yaml"                  # Virtualization overrides - good for LXC
      - "os/%{os.name}-%{os.release.major}.yaml"   # OS name, version specific
      - "os/%{os.family}.yaml"                     # OS family,  generic 
      - "site.yaml"                                # Common to all nodes
  - name: "Roles from assigned variables in Bolt inventory"
    mapped_paths:
      - roles
      - role
      - "roles/%{role}.yaml"
```
Here's an example of a YAML hiera data file to deploy a GitLab server using a role
assignment based on variables from the Bolt inventory.  Since this role is using the
'gitlab' and 'firewalld' classes, ensure that the modules are available to the Bolt
project.
```
---
# Install and configure GitLab Enterprise

classes:
  - gitlab
  - firewalld

types::types:
  - firewalld_service

types::package:
  git:
    ensure: installed
  policycoreutils:
    ensure: installed
  postfix:
    ensure: installed

types::user:
  git:
    ensure: present
    system: true
    home: /var/opt/gitlab
    gid: git
    require: 'Group[git]'

types::group:
  git:
    ensure: present
    system: true    
    before: File[/etc/gitlab]

types::file:
  /etc/sysctl.d/90-gitlab.conf:
    ensure: file
    content: |
      # FILE MANAGED BY PUPPET
      vm.swappiness = 1

types::firewalld_service:
  http:
    ensure: present
    service: http

gitlab::external_url: http://%{fqdn}
gitlab::manage_upstream_edition: ee
gitlab::service_manage: true
gitlab::service_provider_restart: true
```

## Feedback

Please use the [project wiki on github](https://github.com/southalc/types/wiki) for feedback, questions,
or to share your creative use of this module.

## Development

This module is under lazy development and is unlikely to get much attention. That said, it's pretty
simple and unlikely to need much upkeep.
