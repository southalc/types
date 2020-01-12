# defined type as a replacement for create_resources() using abstracted
# resource types as documented here:
# https://puppet.com/docs/puppet/5.5/lang_resources_advanced.html
# The type should be called by the resource type being created, with '$hash'
# containing a hash of instances of the called type and the parameters of each
# instance.  The optional 'defaults' hash is useful in reducing the amount of
# data needed when declaring many instances with similar attributes.

define types::type (
  Hash $hash,
  $defaults = {}
) {
  $hash.each |$instance, $properties| {
    Resource[$name] {
      $instance: * => $properties;
      default:   * => $defaults;
    }
  }
}
