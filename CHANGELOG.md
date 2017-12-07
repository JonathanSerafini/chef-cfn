chef\_cfn changelog
===================

v2.1.2
------
* Version-locked aws-ruby-sdk to '~> v2.10.98'

v2.1.1
------
* Add missing cloudwatch configuration attributes

v2.1.0
------
* Add cloudwatch events report handler

v2.0.3
------
* Add missing ohai feature flag
* Remove additional cfn init modules

v2.0.2
------
* cloud-init bugfixes
* awslogs service bugfix

v2.0.1
------
* Bugfixes

v2.0.0
------
* Refactor code for cookstyle
* Add recipe feature flags to disable some recipes
* Add boolean to disable cloudformation handler
* Add awslogs installation

v1.0.0
------
* Update ohai recipes to rely on the newer ohai v4+ format

v0.9.2
------
* Rubocop auto-correct Style/StringLiterals
* Rubocop auto-correct Style/TrailingBlankLines
* Rubocop auto-correct Style/TrailingWhitespace
* Rubocop auto-correct Lint/DeprecatedClassMethods
* Rubocop auto-correct Style/SpaceAroundEqualsInParameterDefault
* Rubocop auto-correct Style/ExtraSpacing
* Rubocop auto-correct Style/SpaceAfterComma
* Rubocop auto-correct Style/SpaceAroundOperators
* Rubocop auto-correct Style/AndOr

v0.9.1
------
* Ongoing work

v0.1.0
------
* Initial release of chef_cfn
