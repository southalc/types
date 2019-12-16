# Create binary files from base64 encoded data
#
# Defined type accepts the parameter 'properties' that contains the same
# properties as the native `File` type, with only difference being that the
# `content` should be a base64 encoded string.
# The 'defaults' parameter can also be passed as a simple 'key'='value' hash
# that may be useful in reducing the amount of data to be defined for each
# resource.

define types::binary (
  Hash $properties,
  $defaults = lookup('types::binary::defaults', Hash, 'hash', {})
) {
  $content = base64('decode',$properties['content'])
  $file_data = merge($properties, { content => $content})

  File { $name:
    * => $file_data;
    default: * => $defaults;
  }
}
