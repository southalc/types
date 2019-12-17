# Generic class uses hiera hashes with simple iteration to implement ANY
# resource type.  This enables resource management through simple hiera
# files without the need to write any puppet code.  Types from additional
# modules can be used simply by adding the type(s) to `types` parameter
# and defining the new resources in the hiera hash `types::<type_name>`

class types (
  Array $types,
  Hash $merge,
) {

  # If Puppet version is less than 6.x, include deprecated types
  $puppet_majver = Integer(split($::clientversion, '[.]')[0])
  if $puppet_majver < 6 {
    $all_types = unique(
      lookup('types::native_types') +
      lookup('types::deprecated_types') +
      $types
    )
  } else {
    $all_types = unique(lookup('types::native_types') + $types)
  }

  $all_types.each |String $type| {
    $hash = lookup("types::${type}", Hash, $merge, {})
    case $type {
      'binary': {
        $hash.each |String $binary, Hash $properties| {
          Types::Binary { $binary: properties => $properties }
        }
      }
      default: {
        Types::Type { $type: hash => $hash, }
      }
    }
  }
}
