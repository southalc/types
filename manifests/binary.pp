# Create binary files from base64 encoded data

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
