# IAS RRD Tool Backup Scripts

When RRD Tool files get large and you need to convert them to XML
the resultant files are larger.  This repo is for tools managing
backups of RRD Tool files.

## Description

* rrdtool_backup_dir.sh - individually converts files in a directory to xml in
the destination directory, and gzips them.

# Installation

The script will run fine when just checked out.  Optionally, you can build a package
which will install the binaries in /opt/IAS/bin/ias-rrdtool-backup-scripts/.

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

