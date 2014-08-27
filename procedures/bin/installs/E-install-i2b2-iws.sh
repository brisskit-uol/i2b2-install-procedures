#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Installs the 'i2b2' WS that acts as an interface between CiviCRM and i2b2.:
#
# Mandatory: the I2B2_INSTALL_PROCS_HOME environment variable to be set.
# Optional : the I2B2_INSTALL_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the install home.
#
# Pre-reqs:
#   1-acquisitions.sh has been run at some point to acquire the install artifacts.
#
# USAGE: {script-file-name}.sh job-name
# Where: 
#   job-name is a suitable tag to group all jobs associated with the overall workflow
# Notes:
#   The job-name is used to create a work directory for the overall workflow; eg:
#   I2B2_INSTALL_PROCS_HOME/job-name
#   This work directory must already exist.
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
WORK_DIR=$I2B2_INSTALL_WORKSPACE/$JOB_NAME
LOG_FILE=$WORK_DIR/$JOB_LOG_NAME

#
# We must already have a work directory for this job step
# (otherwise no acquisitions)...
if [ ! -d $WORK_DIR ]
then
	echo "Error! Could not find work directory."
	echo "Please check acquisitions step has been run and that job name \"$JOB_NAME\" is correct."
	exit 1
fi

#===========================================================================
# Print a banner for this step of the job.
#===========================================================================
print_banner $( basename $0 ) $JOB_NAME $LOG_FILE 

#===========================================================================
# The real work is about to start.
# Give the user a warning...
#=========================================================================== 
echo "About to install the 'i2b2' web service within the JBoss web server..."
echo ""
echo "   Please note detailed log messages are written to $LOG_FILE"
echo "   If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

#
# Create the intermediate PDO directory if it does not already exist...
if [ ! -d $PDO_DIRECTORY ]
then
    mkdir $PDO_DIRECTORY
    exit_if_bad $? "Failed to create PDO audit directory: $PDO_DIRECTORY"
fi

#==============================
# Verify JBOSS is not running.
#===============================
stopjboss

#
# Install i2b2 WS war file into JBoss...
#
print_message "" $LOG_FILE
print_message "Installing i2b2WS war file." $LOG_FILE
cp $WORK_DIR/$ACQUISITIONS_DIRECTORY/$( basename $I2B2_INTEGRATION_WS_DOWNLOAD_PATH ) $JBOSS_HOME/standalone/deployments/i2b2WS.war
exit_if_bad $? "Failed to copy i2b2 web service war file into $JBOSS_HOME/standalone/deployments" $LOG_FILE

#
# And copy its configuration file into the appropriate directory...
#
cp $I2B2_INSTALL_PROCS_HOME/config/integration/webservice.properties $I2B2_INSTALL_DIRECTORY
exit_if_bad $? "Failed to copy i2b2 web service properties file into $I2B2_INSTALL_DIRECTORY" $LOG_FILE

#
# Create the JBoss manual deploy file...
#
touch $JBOSS_HOME/standalone/deployments/i2b2WS.war.dodeploy
exit_if_bad $? "Failed to create the JBoss manual deploy file i2b2WS.war.dodeploy" $LOG_FILE

#====================================
# START JBOSS (as a background task)
#====================================
startjboss ${LOG_FILE}

#=========================================================================
# If we got this far, we must be successful...
#=========================================================================
print_message "i2b2 WS installation completed." $LOG_FILE
print_footer $( basename $0 ) $JOB_NAME $LOG_FILE