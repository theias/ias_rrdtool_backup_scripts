PROJECT_NAME = ias-rrdtool-backup-scripts
RELEASE_VERSION := $(shell cat ./$(PROJECT_NAME)/changelog | grep -v '^\s+$$' | head -n 1 | awk '{print $$2}')
ARCH := $(shell cat ./$(PROJECT_NAME)/changelog | grep -v '^\s+$$' | head -n 1 | awk '{print $$3}'|sed 's/;//')
SRC_VERSION := $(shell echo '$(RELEASE_VERSION)' | awk -F '-' '{print $$1}')
PKG_VERSION := $(shell echo '$(RELEASE_VERSION)' | awk -F '-' '{print $$2}')

DROP_DIR = $(shell echo `pwd`/drop)
SRC_DIR = $(shell echo `pwd`/src)
BUILD_DIR = $(shell echo `pwd`/build)
SPEC_FILE_NAME = $(PROJECT_NAME)-$(RELEASE_VERSION)--pkginfo.spec
SPEC_FILE = $(BUILD_DIR)/$(SPEC_FILE_NAME)
ROOT_DIR = $(BUILD_DIR)/root
BASE_DIR = /opt/IAS
INST_DIR = $(BASE_DIR)/$(PROJECT_NAME)
FAKE_INST_DIR = $(ROOT_DIR)$(INST_DIR)

BIN_DIR=$(BASE_DIR)/bin/$(PROJECT_NAME)
BIN_INST_DIR=$(ROOT_DIR)/$(BIN_DIR)

CGI_BIN_DIR=$(BASE_DIR)/cgi-bin/$(PROJECT_NAME)
CGI_BIN_INST_DIR=$(ROOT_DIR)/$(CGI_BIN_DIR)

LIB_DIR=$(BASE_DIR)/lib
LIB_INST_DIR=$(ROOT_DIR)/$(LIB_DIR)

DOC_DIR=$(BASE_DIR)/doc/$(PROJECT_NAME)
DOC_INST_DIR=$(ROOT_DIR)$(DOC_DIR)

# Directories for FullProjectPath type apps:
INPUT_DIR=$(BASE_DIR)/input/$(PROJECT_NAME)
OUTPUT_DIR=$(BASE_DIR)/output/$(PROJECT_NAME)
CONF_DIR=$(BASE_DIR)/etc/$(PROJECT_NAME)
LOG_DIR=$(BASE_DIR)/log/$(PROJECT_NAME)
TEMPLATE_DIR=$(BASE_DIR)/templates/$(PROJECT_NAME)

DEB_DIR=$(ROOT_DIR)/DEBIAN
DEB_CONTROL_FILE=$(DEB_DIR)/control
DEB_CONF_FILES_FILE=$(DEB_DIR)/conffiles

SUMMARY := $(shell egrep '^Summary:' ./$(PROJECT_NAME)/rpm_specific | awk -F ':' '{print $$2}')


all:

clean:
	-rm -rf build

debug:
	# PROJECT_NAME: $(PROJECT_NAME)
	# RELEASE_VERSION: $(RELEASE_VERSION)
	# ARCH: $(ARCH)
	# SRC_VERSION: $(SRC_VERSION)
	# PKG_VERSION: $(PKG_VERSION)
	# DROP_DIR: $(DROP_DIR)
	# BUILD_DIR: $(BUILD_DIR)
	# SPEC_FILE_NAME: $(SPEC_FILE_NAME)
	# SPEC_FILE: $(SPEC_FILE)
	# SRC_DIR: $(SRC_DIR)
	# ROOT_DIR: $(ROOT_DIR)
	# BASE_DIR: $(BASE_DIR)
	# INST_DIR: $(INST_DIR)
	# FAKE_INST_DIR: $(FAKE_INST_DIR)

	# BIN_DIR: $(BIN_DIR)
	# BIN_INST_DIR: $(BIN_INST_DIR)

	# CGI_BIN_DIR: $(CGI_BIN_DIR)
	# CGI_BIN_INST_DIR: $(CGI_BIN_INST_DIR)

	# LIB_DIR: $(LIB_DIR)
	# LIB_INST_DIR: $(LIB_INST_DIR)
	
	# DOC_DIR: $(DOC_DIR)
	# DOC_INST_DIR: $(DOC_INST_DIR)

	# INPUT_DIR: $(INPUT_DIR)
	# OUTPUT_DIR: $(OUTPUT_DIR)
	# CONF_DIR: $(CONF_DIR)
	# LOG_DIR: $(LOG_DIR)
	# TEMPLATE_DIR $(TEMPLATE_DIR)

package-rpm: clean all install rpmspec rpmbuild

package-deb: clean all install debsetup debbuild

release: test-all

test-all: test test-doc

test:
	
	# Sytax checking routines.
ifneq ("$(wildcard $(SRC_DIR)/bin/*.pl)","")
	# Running Perl Tests
	find $(SRC_DIR/bin) -type f \
		-name '*.pl' \
	| xargs -r perl -c 
	
endif

ifneq ("$(wildcard $(SRC_DIR)/bin/*.sh)","")
	# Running Bash Tests
	find $(SRC_DIR/bin) -type f \
		-name '*.sh' \
	| xargs -r -n1 bash -n 
	
endif

ifneq ("$(wildcard $(SRC_DIR)/bin/*.py)","") 
	# Running Python Tests
	find $(SRC_DIR/bin) -type f \
		-name '*.py' \
	| xargs -r -n1 python -m py_compile
endif

ifneq ("$(wildcard $(SRC_DIR)/bin/*.rb)","")
	# Running Ruby Tests
	find $(SRC_DIR/bin) -type f \
		-name '*.rb' \
	| xargs -r -n1 ruby -c
endif

test-doc:
	find $(SRC_DIR) -type f \
		-name '*.pl' \
		-o -name '*.pm' \
	| xargs -r podchecker
	
builddir:
	if [ ! -d build ]; then mkdir build; fi;

install: builddir
	################
	# Simplest form: all things from src get copied
	# into the installation directory
	# mkdir -p $(FAKE_INST_DIR)
	# cp -r $(SRC_DIR)/* $(FAKE_INST_DIR)/
	# -find $(FAKE_INST_DIR) -name '*.pl' | xargs -r chmod 755
	# -find $(FAKE_INST_DIR) -name '*.sh' | xargs -r chmod 755
	# -find $(FAKE_INST_DIR) -name '*.py' | xargs -r chmod 755
	
	###############
	# Slightly more complicated:
	# Stuff is divided up

# Docs by default are added.
	mkdir -p $(DOC_INST_DIR)
	cp $(PROJECT_NAME)/changelog $(DOC_INST_DIR)/
	cp $(PROJECT_NAME)/description $(DOC_INST_DIR)/
	cp README* $(DOC_INST_DIR)
	-cp -r run_scripts $(DOC_INST_DIR)
	find $(DOC_INST_DIR) -type f | xargs chmod 644

	# Directories for FullProjectPath type apps:

	mkdir -p $(ROOT_DIR)/$(INPUT_DIR)
	mkdir -p $(ROOT_DIR)/$(OUTPUT_DIR)
	mkdir -p $(ROOT_DIR)/$(LOG_DIR)

# Conditional additions

# Bin
ifneq ("$(wildcard $(SRC_DIR)/bin/*)","") 
		mkdir -p $(ROOT_DIR)/$(BIN_DIR)
		-cp -r $(SRC_DIR)/bin/* $(ROOT_DIR)/$(BIN_DIR)
		-find $(BIN_INST_DIR) -type f | xargs -r chmod 755
endif

# cgi-bin
ifneq ("$(wildcard $(SRC_DIR)/cgi-bin/*)","") 
		mkdir -p $(ROOT_DIR)/$(CGI_BIN_DIR)
		-cp -r $(SRC_DIR)/cgi-bin/* $(ROOT_DIR)/$(CGI_BIN_DIR)
		-find $(CGI_BIN_INST_DIR) -type f | xargs -r chmod 755
endif
	
# Templates
ifneq ("$(wildcard $(SRC_DIR)/templates/*)","") 
	mkdir -p $(ROOT_DIR)/$(BASE_DIR)/templates
	cp -r $(SRC_DIR)/templates $(ROOT_DIR)/$(TEMPLATE_DIR)
	find $(ROOT_DIR)/$(TEMPLATE_DIR) -type f | xargs -r chmod 644
endif


# lib
ifneq ("$(wildcard $(SRC_DIR)/lib/*)","")	
	mkdir -p $(LIB_INST_DIR)
	cp -r $(SRC_DIR)/lib/* $(LIB_INST_DIR)
	find $(SRC_DIR)/lib/ | xargs -r chmod 644
endif


# /opt/IAS/(something)/etc
ifneq ("$(wildcard $(SRC_DIR)/etc/*)","")
	mkdir -p $(ROOT_DIR)/$(CONF_DIR)
	cp -r $(SRC_DIR)/etc/* $(ROOT_DIR)/$(CONF_DIR)/
	chmod 0644 $(ROOT_DIR)/$(CONF_DIR)
endif

# /etc/
ifneq ("$(wildcard $(SRC_DIR)/root_etc/*)","")
	cp -r $(SRC_DIR)/root_etc $(ROOT_DIR)/etc
	chmod -R 0644 $(ROOT_DIR)/etc
endif

	################
	# Some Final Cleanup	
	chmod -R a+r $(ROOT_DIR)
	-find $(ROOT_DIR) -type d |xargs chmod a+rx
	-find $(ROOT_DIR) -type d -name .svn | xargs -r rm -r
	
	################
	# An example of creating a file owned by
	# a non-root user (your system must have
	# fakeroot installed and working):
	# touch $(ROOT_DIR)/drop
	# chown somegroup:somegroup $(ROOT_DIR)/drop
	

rpmspec: install
	echo "" > $(SPEC_FILE)
	echo "Name: $(PROJECT_NAME)" >> $(SPEC_FILE)
	echo "Version: $(SRC_VERSION)" >> $(SPEC_FILE)
	echo "Release: $(PKG_VERSION)" >> $(SPEC_FILE)
	echo "BuildArch: $(ARCH)" >> $(SPEC_FILE)
	echo `svn info |grep '^URL:'` >> $(SPEC_FILE)
	echo "Packager: $$USER" >> $(SPEC_FILE)
	
	# cat ./$(PROJECT_NAME)/pkginfo >> $(SPEC_FILE)
	cat ./$(PROJECT_NAME)/rpm_specific >> $(SPEC_FILE)
	for file in $(PROJECT_NAME)/install_scripts/*; do echo "%"`basename $$file` >> $(SPEC_FILE); cat $$file >> $(SPEC_FILE); done
	echo "%description" >> $(SPEC_FILE)
	cat ./$(PROJECT_NAME)/description >> $(SPEC_FILE)
	echo "" >> $(SPEC_FILE)

	echo "%files" >> $(SPEC_FILE)

	# These are created by default
	echo "%defattr(644, root, root, 755)" >> $(SPEC_FILE)
	echo "$(DOC_DIR)" >> $(SPEC_FILE)
	
	echo "%defattr(664, root, root, 755) " >> $(SPEC_FILE)
	echo "$(INPUT_DIR)" >> $(SPEC_FILE)
	
	echo "%defattr(664, root, root, 755) " >> $(SPEC_FILE)
	echo "$(OUTPUT_DIR)" >> $(SPEC_FILE)
	
	echo "%defattr(664, root, root, 755) " >> $(SPEC_FILE)
	echo "$(LOG_DIR)" >> $(SPEC_FILE)

# Binaries
ifneq ("$(wildcard $(SRC_DIR)/bin/*)","")
	echo "%defattr(755, root, root, 755) " >> $(SPEC_FILE)
	echo "$(BIN_DIR)" >> $(SPEC_FILE)
endif

# cgi-bin
ifneq ("$(wildcard $(SRC_DIR)/cgi-bin/*)","")
	echo "%defattr(755, root, root, 755) " >> $(SPEC_FILE)
	echo "$(CGI_BIN_DIR)" >> $(SPEC_FILE)
endif

# Templates
ifneq ("$(wildcard $(SRC_DIR)/templates/*)","")	
	echo "%defattr(664, root, root, 755) " >> $(SPEC_FILE)
	echo "$(TEMPLATE_DIR)" >> $(SPEC_FILE)
endif

# Libraries
ifneq ("$(wildcard $(SRC_DIR)/lib/*)","")
	echo "%defattr(644, root, root,755) " >> $(SPEC_FILE)
	echo "$(LIB_DIR)" >> $(SPEC_FILE)
endif

# Project Config, example /opt/IAS/etc/(project-name)
ifneq ("$(wildcard $(SRC_DIR)/etc/*)","")
	echo "%defattr(644, root, root,755) " >> $(SPEC_FILE)
	echo "%dir $(CONF_DIR)" >> $(SPEC_FILE)
	-find $(ROOT_DIR)/$(CONF_DIR) -type f | sed -r "s|$(ROOT_DIR)|%config |"  >> $(SPEC_FILE)
endif

ifneq ("$(wildcard $(SRC_DIR)/root_etc/*)","")
	# /etc/ config files
	-find $(ROOT_DIR)/etc -type f |  sed -r "s|$(ROOT_DIR)|%config(noreplace) |" >> $(SPEC_FILE)
endif


cp-rpmspec: builddir
	cp $(PROJECT_NAME)/$(SPEC_FILE_NAME) $(SPEC_FILE)

rpmbuild:
	rpmbuild --buildroot $(ROOT_DIR) -bb $(SPEC_FILE) --define '_topdir $(BUILD_DIR)' --define '_rpmtopdir $(BUILD_DIR)'
	
debsetup:
	mkdir -p $(DEB_DIR)
	echo "Package: " $(PROJECT_NAME) >> $(DEB_CONTROL_FILE)
	echo "Version: " $(RELEASE_VERSION) >> $(DEB_CONTROL_FILE)
	cat $(PROJECT_NAME)/deb_control >> $(DEB_CONTROL_FILE)
	
	echo "Description: " $(SUMMARY) >> $(DEB_CONTROL_FILE)
	cat ./$(PROJECT_NAME)/description | egrep -v '^\s*$$' | sed 's/^/ /' >> $(DEB_CONTROL_FILE)

# Project Config, example /opt/IAS/etc/(project-name)
ifneq ("$(wildcard $(SRC_DIR)/etc/*)","")
	-find $(ROOT_DIR)/$(CONF_DIR) -type f | sed -r "s|$(ROOT_DIR)||" >> $(DEB_CONF_FILES_FILE)
endif

ifneq ("$(wildcard $(SRC_DIR)/root_etc/*)","")
	# /etc/ config files
	-find $(ROOT_DIR)/etc -type f |  sed -r "s|$(ROOT_DIR)||" >> $(DEB_CONF_FILES_FILE)
endif
	
debbuild:
	dpkg-deb --build $(ROOT_DIR) $(BUILD_DIR)
