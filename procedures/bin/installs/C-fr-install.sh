#!/bin/bash
#--------------------------------------------------------------------------------------------
#
# Install script for i2b2 File Repository cell
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
#   The job-name is used to locate a work directory for the overall workflow; eg:
#   I2B2_INSTALL_PROCS_HOME/job-name
#   This work directory must already exist.
#
# Further tailoring can be achieved via the defaults.sh script.
#
# NOTES. Jeff: There are some aspects of this I still don't understand
# (1) The REPO_LOCATION needs to be assigned in some way so the system can find it.
#     I think this accomplished via the web client. At least the documentation 
#     might lead you to believe so. See the FRC installation guide...
#     a) Logon to Project Manager Web Interface, select ‘Hive’ and highlight FR Cell 
#     b) Then it states 
#        "Enter the parameters by selecting the row that has the ‘FRC’ as the ID.
#         PathSeparator is the default path separator for the host machine running the cell,
#         on Mac OS and Linux is it /, while on Windows it is \
#         DestDir is the destination where the files will be hosted."
#     There is more related to admin users and SFTP, which please see.
#
#     It would be far better if this were also available via script rather 
#     than a gui interface. This may yet be possible. Requires further investigation.
#
# (2) Stops and starts JBoss.
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
echo "About to install i2b2 file repository cell..."
echo ""
echo "   Please note detailed log messages are written to $LOG_FILE"
echo "   If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

#==============================
# Verify JBOSS is not running.
#===============================
stopjboss

#
# Copy some build/config files to required locations and substitute variables...
merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/merge-files/$DB_TYPE/fr-cell/build.properties \
             $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.fr/build.properties
exit_if_bad $? "Failed to merge properties into $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.fr/build.properties" $LOG_FILE

merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/merge-files/$DB_TYPE/fr-cell/fr_application_directory.properties \
             $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.fr/etc/spring/fr_application_directory.properties
exit_if_bad $? "Failed to merge properties into $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.fr/etc/spring/fr_application_directory.properties" $LOG_FILE

merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/merge-files/$DB_TYPE/fr-cell/edu.harvard.i2b2.fr.properties \
             $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.fr/etc/spring/edu.harvard.i2b2.fr.properties
exit_if_bad $? "Failed to merge properties into $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.fr/etc/spring/edu.harvard.i2b2.fr.properties" $LOG_FILE

#============================
# Deploy File Repository cell
#============================
print_message "" $LOG_FILE
print_message "About to deploy File Repository cell." $LOG_FILE

cd $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.fr
$ANT_HOME/bin/ant -f master_build.xml \
                  clean build-all deploy \
                  >>$LOG_FILE 2>>$LOG_FILE 
exit_if_bad $? "Failed to deploy File Repository cell." $LOG_FILE
print_message "Success! File Repository cell deployed." $LOG_FILE

#============================================================
# Create a directory on the server to host the files.
# Should have the same privileges as the user running JBoss.
#============================================================
mkdir -p $FILE_REPO_LOCATION
exit_if_bad $? "Failed to create File Repository location." $LOG_FILE

#====================================
# START JBOSS (as a background task)
#====================================
startjboss ${LOG_FILE} "In a browser, use the following URL to verify FRService is listed as active: ${LIST_SERVICES_URL}"

#=========================================================================
# If we got this far, we must be successful (hopefully) ...
#=========================================================================
print_message "File Repository install complete." $LOG_FILE
print_footer $( basename $0 ) $JOB_NAME $LOG_FILE