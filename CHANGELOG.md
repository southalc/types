## Release 0.3.5

- No functional changes.
- Bumped module metadata to support latest puppet and dependency versions.
- Updated PDK and linted.

## Release 0.3.4

- No functional changes. Bumped module dependencies to include the latest versions.

## Release 0.3.3

**Features**

- Added basic unit tests
- Add tags to module metadata

**Bugfix**

- Bolt plan now uses 'out::message' to display the ApplyResult message for each target
- Declare the data type on the 'defaults' parameter for 'type'

## Release 0.3.2

- No functional changes.  Updated metadata to support puppet 7

## Release 0.3.1

**Features**

- Added documentation using puppet strings

**Bugfix**

- Bolt plan can use apply_prep_params to customize puppet agent installation

## Release 0.3.0

**Features**

- Added a simple Bolt plan enabling Puppet catalogs to be built from hiera data
and pushed to otherwise unmanaged targets. 

## Release 0.2.1

**Bugfix**
- Typo in module hiera including the 'selboolean' class

## Release 0.2.0

**Features**

- Enabled default attributes for all types, reducing the amount of data required
in hiera when defining many resources with similar attributes.

## Release 0.1.1

**Bugfixes**
- Added `stdlib` to module dependencies

## Release 0.1.0

**Features**

Initial release
