# Create a file with content from base64 encoded data

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
