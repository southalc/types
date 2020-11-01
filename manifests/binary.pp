# @summary Defined type to create files from base64 encoded data
#
# @param properties Hash
#   Properties match the standard file resource, but 'content' must be a base64
#   encoded string.
#
# @param defaults
#   A hash of default values to be used when creating resources
#
define types::binary (
  Hash $properties,
  Hash $defaults = {},
) {
  $content = base64('decode', $properties['content'])
  $file_data = merge($properties, { content => $content})

  File { $name:
    * => $file_data;
    default: * => $defaults;
  }
}
