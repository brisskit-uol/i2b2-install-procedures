#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Installs all artifacts required by the basic i2b2 install:
#
# Mandatory: the I2B2_INSTALL_PROCS_HOME environment variable to be set.
# Optional : the I2B2_INSTALL_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the install home.
#
# Pre-reqs:
#   install-all.sh has been run at some point to acquire the JDK
#
# USAGE: {script-file-name}.sh job-name
# Where: 
#   job-name is a suitable tag to group all jobs associated with the overall workflow
# Notes:
#   The job-name is used to create a work directory for the overall workflow; eg:
#   I2B2_INSTALL_PROCS_HOME/job-name
#   This work directory must already exist.
#
# Author: Jeff Lusted (jl99@leicester.ac.uk)
#-----------------------------------------------------------------------------------------------
source $I2B2_INSTALL_PROCS_HOME/bin/common/setenv.sh
source $I2B2_INSTALL_PROCS_HOME/bin/common/functions.sh

#=======================================================================
# First, some basic checks...
#=======================================================================
#
# Check on the usage...
if [ ! $# -eq 1 ]
then
	echo "Error! Incorrect number of arguments."
	echo ""
	print_usage
	exit 1
fi

#
# Retrieve job-name into its variable...
JOB_NAME=$1

$I2B2_INSTALL_PROCS_HOME/bin/installs/1a-prerequisites.sh $JOB_NAME
$I2B2_INSTALL_PROCS_HOME/bin/installs/1b-acquisitions.sh $JOB_NAME
$I2B2_INSTALL_PROCS_HOME/bin/installs/1c-install-ant.sh $JOB_NAME
$I2B2_INSTALL_PROCS_HOME/bin/installs/1d-install-jdk.sh $JOB_NAME
$I2B2_INSTALL_PROCS_HOME/bin/installs/2-install-jboss.sh $JOB_NAME
$I2B2_INSTALL_PROCS_HOME/bin/installs/3-data-install.sh $JOB_NAME
$I2B2_INSTALL_PROCS_HOME/bin/installs/4-pm-install.sh $JOB_NAME
$I2B2_INSTALL_PROCS_HOME/bin/installs/5-ont-install.sh $JOB_NAME
$I2B2_INSTALL_PROCS_HOME/bin/installs/6-crc-install.sh $JOB_NAME
$I2B2_INSTALL_PROCS_HOME/bin/installs/7-work-install.sh $JOB_NAME
$I2B2_INSTALL_PROCS_HOME/bin/installs/8-fr-install.sh $JOB_NAME
$I2B2_INSTALL_PROCS_HOME/bin/installs/9-install-i2b2-iws.sh $JOB_NAME
$I2B2_INSTALL_PROCS_HOME/bin/installs/A-install-i2b2-admin-procedures.sh $JOB_NAME

