# @summary Manage any type or defined type from hiera
#
# @param types
#   Adds support for additional types or defined types.
#
# @param merge
#   Manage the merge behavior for hiera lookups.
#
class types (
  Array $types,
  Hash $merge,
) {
  # If Puppet version is less than 6.x, include deprecated types
  $puppet_majver = Integer(split(fact(clientversion), '[.]')[0])
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
        $defaults = lookup('types::binary_defaults', Hash, hash, {})
        $hash.each |String $binary, Hash $properties| {
          Types::Binary { $binary:
            properties => $properties,
            defaults   => $defaults,
          }
        }
      }
      default: {
        Types::Type { $type:
          hash     => $hash,
          defaults => lookup("types::${type}_defaults", Hash, hash, {}),
        }
      }
    }
  }
}
