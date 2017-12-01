# IAS RRD Tool Backup Scripts

When RRD Tool files get large and you need to convert them to XML
the resultant files are larger.  This repo is for tools managing
backups of RRD Tool files.

# License
copyright (C) 2017 Martin VanWinkle, Institute for Advanced Study

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

See 

* http://www.gnu.org/licenses/

## Description

* rrdtool_backup_dir.sh - individually converts files in a directory to xml in
the destination directory, and gzips them.

# Installation

You can just download the individual file and run it, or clone the git repo.

The script should run just fine in any case.

Optionally, you can build a package which will install the binaries in

* /opt/IAS/bin/ias-rrdtool-backup-scripts/.

# Building a Package

## Requirements

### All Systems

* fakeroot

### Debian

* build-essential

### RHEL based systems

* rpm-build

## Export a specific tag (or just the source directory)

## Supported Systems

### Debian packages

<pre>
  fakeroot make clean install debsetup debbuild
</pre>

### RHEL Based Systems

If you're building from a tag, and the spec file has been put
into the tag, then you can build this on any system that has
rpm building utilities installed, without fakeroot:

<pre>
make clean install cp-rpmspec rpmbuild
</pre>

This will generate a new spec file every time:

<pre>
fakeroot make clean install rpmspec rpmbuild
</pre>

# License


