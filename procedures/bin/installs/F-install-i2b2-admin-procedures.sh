#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Installs i2b2 admin procedures:
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
#   The job-name is used to focus on a work directory for the overall workflow; eg:
#   I2B2_INSTALL_PROCS_HOME/job-name
#   This work directory must already exist.
#
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
echo "About to install i2b2 admin procedures"
echo ""
echo "   Please note detailed log messages are written to $LOG_FILE"
echo "   If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

#
# Unzip i2b2 admin procedures file...
print_message "" $LOG_FILE
print_message "Unzipping  i2b2 admin procedures file..." $LOG_FILE
unzip -o $WORK_DIR/$ACQUISITIONS_DIRECTORY/$( basename $I2B2_ADMIN_PROCEDURES_DOWNLOAD_PATH ) -d $I2B2_INSTALL_DIRECTORY >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to unzip i2b2 admin procedures to $I2B2_INSTALL_DIRECTORY" $LOG_FILE

#
# Make them a little more restrictive...
chmod -R o-w,o+x $I2B2_INSTALL_DIRECTORY/i2b2*admin-procedures*

#
# A couple of symbolic links makes things a little easier...
ln -s ${I2B2_INSTALL_DIRECTORY}/i2b2*admin-procedures* ${I2B2_INSTALL_DIRECTORY}/i2b2-admin-procedures
ln -s ${I2B2_INSTALL_DIRECTORY}/i2b2*install-procedures* ${I2B2_INSTALL_DIRECTORY}/i2b2-install-procedures

#
# Set up the cronjob for periodic uploads of export data to i2b2.
# NB: There is a workaround here. The crontab command seems to be limited
#     in the length of the file path that can be passed to it as a target. So:
#     (1) The current directory path is saved
#     (2) We cd into the crontab target's file directory 
#     (3) Do the crontab
#     (4) Restore current directory.
print_message "" $LOG_FILE
print_message "Setting up cronjob for periodic uploads of export data to i2b2" $LOG_FILE
CURRENT_DIRECTORY=`pwd`
cd ${I2B2_INSTALL_PROCS_HOME}/config/integration
sudo -u ${SSH_INTEGRATION_USER} crontab ./cron-params
exit_if_bad $? "Failed to set up cronjob for periodic uploads of export data to i2b2" $LOG_FILE
cd ${CURRENT_DIRECTORY}

#=========================================================================
# If we got this far, we must be successful...
#=========================================================================
print_message "i2b2 admin procedures installation completed." $LOG_FILE
print_footer $( basename $0 ) $JOB_NAME $LOG_FILE