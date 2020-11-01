# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

* [`types`](#types): Manage any type or defined type from hiera

### Defined types

* [`types::binary`](#typesbinary): Defined type to create files from base64 encoded data
* [`types::type`](#typestype): Defined type uses abstract resource types to implement all types

### Plans

* [`types::hiera`](#typeshiera): A simple Bolt plan to deploy resources defined in hiera

## Classes

### `types`

Manage any type or defined type from hiera

#### Parameters

The following parameters are available in the `types` class.

##### `types`

Data type: `Array`

Adds support for additional types or defined types.

##### `$merge`

Manage the merge behavior for hiera lookups.

##### `merge`

Data type: `Hash`



## Defined types

### `types::binary`

Defined type to create files from base64 encoded data

#### Parameters

The following parameters are available in the `types::binary` defined type.

##### `properties`

Data type: `Hash`

Hash
Properties match the standard file resource, but 'content' must be a base64
encoded string.

##### `defaults`

Data type: `Hash`

A hash of default values to be used when creating resources

Default value: `{}`

### `types::type`

Defined type uses abstract resource types to implement all types

#### Parameters

The following parameters are available in the `types::type` defined type.

##### `hash`

Data type: `Hash`

Hash
Contains one or more resource definitions of a given type to be created

##### `defaults`

Data type: `Any`

Hash
Default values used for all resource definitions of a given type

Default value: `{}`

## Plans

### `types::hiera`

A simple Bolt plan to deploy resources defined in hiera

#### Parameters

The following parameters are available in the `types::hiera` plan.

##### `apply_prep_params`

Data type: `Hash`

A optional hash of values used by the `puppet_agent::install` task, which is invoked when Bolt runs
the "apply_prep" function

Default value: `{}`

##### `targets`

Data type: `TargetSpec`


