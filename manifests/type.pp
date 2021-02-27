# @summary Defined type uses abstract resource types to implement all types
#
# @param hash Hash
#   Contains one or more resource definitions of a given type to be created
#
# @param defaults Hash
#   Default values used for all resource definitions of a given type
#
define types::type (
  Hash $hash,
  Hash $defaults = {}
) {
  $hash.each |$instance, $properties| {
    Resource[$name] {
      $instance: * => $properties;
      default:   * => $defaults;
    }
  }
}
