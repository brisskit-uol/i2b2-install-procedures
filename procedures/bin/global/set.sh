#!/bin/bash
#-----------------------------------------------------------------------------------------------------------
# Source this at the start of any shell session.
# (There should be no need to do this as sudo or root)
# Use "source ./set.sh" or ". ./set.sh" at the command line or within a composition script.
# Remember, if you execute any script as sudo, then you must inherit the environment variables; eg:
# > sudo -E ./0-prerequisites.sh job-20130214
#
# NOTES.
# (1) Edit setting for I2B2_INSTALL_DIRECTORY.
# (2) Edit setting for INSTALL_PACKAGE_NAME in order to pick up the correct version of the install procedures.
# (3) Edit setting for ADMIN_PACKAGE_NAME in order to pick up the correct version of the admin procedures.
#-----------------------------------------------------------------------------------------------------------
export I2B2_INSTALL_DIRECTORY=/var/local/brisskit/i2b2
INSTALL_PACKAGE_NAME=i2b2-1.5.5-install-procedures-2.0-development-SNAPSHOT
ADMIN_PACKAGE_NAME=i2b2-admin-procedures-3.0-development-SNAPSHOT
export I2B2_INSTALL_PROCS_HOME=$I2B2_INSTALL_DIRECTORY/${INSTALL_PACKAGE_NAME}
export I2B2_ADMIN_PROCS_HOME=${I2B2_INSTALL_DIRECTORY}/${ADMIN_PACKAGE_NAME}