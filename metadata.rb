name             "omnibus_updater"
maintainer       "Chris Roberts"
maintainer_email "chrisroberts.code@gmail.com"
license          "Apache 2.0"
description      "Chef omnibus package updater and installer"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "2.0.3"

depends 'dmg', '= 2.3.1'
