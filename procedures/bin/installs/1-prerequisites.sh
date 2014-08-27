#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Installs gzip, tar, apache2, php5, libapache2-mod-php5, php5-curl if required.
#
# Mandatory: the I2B2_INSTALL_PROCS_HOME environment variable to be set.
# Optional : the I2B2_INSTALL_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the install home.
#
# USAGE: {script-file-name}.sh job-name
# Where: 
#   job-name is a suitable tag to group all jobs associated with the overall workflow
# Notes:
#   The job-name is used to create a working directory for the overall workflow; eg:
#   I2B2_INSTALL_PROCS_HOME/job-name
#   This working directory is created if it does not exist.
#
# Further tailoring can be achieved via the defaults.sh script.
#
# Author: Jeff Lusted (jeff.lusted@gmail.com)
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

#
# It is possible to set your own procedures workspace.
# But if it doesn't exist, we create one for you within the procedures home...
if [ -z $I2B2_INSTALL_WORKSPACE ]
then
	I2B2_INSTALL_WORKSPACE=$I2B2_INSTALL_PROCS_HOME/work
fi

#
# Establish a log file for the job...
LOG_FILE=$I2B2_INSTALL_WORKSPACE/$JOB_NAME/$JOB_LOG_NAME

#
# If required, create a working directory for this job step.
WORK=$I2B2_INSTALL_WORKSPACE/$JOB_NAME
if [ ! -d $WORK ]
then
	mkdir -p $WORK
	exit_if_bad $? "Failed to create working directory $WORK"
fi

#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $( basename $0 ) $JOB_NAME $LOG_FILE 

#===========================================================================
# The real work is about to start.
# Give the user a warning...
#=========================================================================== 
print_message "About to install gzip, tar, apache2, php5, libapache2-mod-php5, php5-curl if required" $LOG_FILE
echo "This may take some time."

sudo apt-get -y --force-yes install gzip
sudo apt-get -y --force-yes install tar
sudo apt-get -y --force-yes install apache2
sudo apt-get -y --force-yes install php5
sudo apt-get -y --force-yes install libapache2-mod-php5
sudo apt-get -y --force-yes install php5-curl
sudo apache2ctl restart

#=========================================================================
# If we got this far, we must be successful?...
#=========================================================================
print_footer $( basename $0 ) $JOB_NAME $LOG_FILE