#!/bin/bash
#
# Install script for i2b2 web client
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
#   I2B2_INSTALL_PROCS_HOME/work/job-name
#   This work directory must already exist.
#
# Further tailoring can be achieved via the defaults.sh script.
#
# NOTES:
# (1) The web client is dependent on an http server running. This install assumes
#     it will be Apache and copies the web client admin source into /var/www/html
#     or similar as defined in the defaults.sh configuration settings.
# (2) Two web clients are installed: an admin and a general client.
#     The general client (known as the "webclient") contains the export plugin.
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
echo "About to install the i2b2 web client..."
echo ""
echo "   Please note detailed log messages are written to $LOG_FILE"
echo "   If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

#
# The web client config data needs Brisskit specific data folding into it beforehand...
merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/config/webclient/i2b2_config_data.js \
             $WORK_DIR/$SOURCE_DIRECTORY/admin/i2b2_config_data.js
exit_if_bad $? "Failed to merge properties into $WORK_DIR/$SOURCE_DIRECTORY/admin/i2b2_config_data.js" $LOG_FILE  

#===============================
# Install the admin web client
#===============================
print_message "" $LOG_FILE
print_message "About to deploy admin web client. Assumes Apache Web Server already running." $LOG_FILE
sudo mkdir -p $HTML_LOCATION
exit_if_bad $? "Failed to create directory $HTML_LOCATION" $LOG_FILE
sudo cp -R $WORK_DIR/$SOURCE_DIRECTORY/admin $HTML_LOCATION
exit_if_bad $? "Failed to deploy i2b2 admin web client." $LOG_FILE

#====================================================================
# Install the general web client, along with the civi export plugin
#====================================================================
print_message "" $LOG_FILE
print_message "About to deploy general web client, along with civi export plugin. Assumes Apache Web Server already running." $LOG_FILE
#
# Create temp directory for unzipping the civi export plugin, and unzip it...
ACQUISITIONS=${WORK_DIR}/$ACQUISITIONS_DIRECTORY 
sudo mkdir ${WORK_DIR}/civi-export-plugin
exit_if_bad $? "Failed to create directory ${WORK_DIR}/civi-export-plugin" $LOG_FILE
CIVI_EXPORT_PLUGIN_ZIP=$( basename $I2B2_CIVI_EXPORT_PLUGIN_DOWNLOAD_PATH )
unzip $ACQUISITIONS/$CIVI_EXPORT_PLUGIN_ZIP -d ${WORK_DIR}/civi-export-plugin >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to unzip civi export plugin zip file: $ACQUISITIONS/$CIVI_EXPORT_PLUGIN_ZIP" $LOG_FILE
#
# First duplicate admin client and overwrite basic settings...
sudo mkdir $HTML_LOCATION/webclient
exit_if_bad $? "Failed to create directory $HTML_LOCATION/webclient" $LOG_FILE
sudo cp -R $WORK_DIR/$SOURCE_DIRECTORY/admin/* $HTML_LOCATION/webclient
exit_if_bad $? "Failed to copy admin client." $LOG_FILE
GEN_WEB_CLIENT=${HTML_LOCATION}/webclient
sudo sed 's/adminOnly: true,\r//' $HTML_LOCATION/admin/i2b2_config_data.js > ${GEN_WEB_CLIENT}/i2b2_config_data.js
exit_if_bad $? "Failed to alter settings in i2b2_config_data.js for general i2b2 web client." $LOG_FILE
#
# Put the "export-files" into the /webclient folder...
sudo cp -R ${WORK_DIR}/civi-export-plugin/export-files $HTML_LOCATION/webclient
exit_if_bad $? "Failed to copy folder export-files into webclient." $LOG_FILE
#
# Put the library "jquery-1.6.1.min.js" in the /webclient/js­ext folder...
sudo cp -R ${WORK_DIR}/civi-export-plugin/js-ext/jquery-1.6.1.min.js $HTML_LOCATION/webclient/js-ext
exit_if_bad $? "Failed to copy library jquery-1.6.1.min.js into webclient/js-ext." $LOG_FILE
#
# Put the folder "ExportXLS" in the /webclient/js­i2b2/cells/plugins/standard folder...
sudo cp -R ${WORK_DIR}/civi-export-plugin/ExportXLS $HTML_LOCATION/webclient/js-i2b2/cells/plugins/standard
exit_if_bad $? "Failed to copy folder ExportXLS into webclient/js­-i2b2/cells/plugins/standard." $LOG_FILE
#
# Copy modified /webclient/default.html to allow the use of jquery library...
sudo cp $I2B2_INSTALL_PROCS_HOME/config/webclient/default.htm $HTML_LOCATION/webclient
exit_if_bad $? "Failed to copy default.html into webclient." $LOG_FILE
#
# Copy modified /webclient/js­i2b2/i2b2loader.js to add the plugin in the analysis tool list...
sudo cp $I2B2_INSTALL_PROCS_HOME/config/webclient/i2b2_loader.js $HTML_LOCATION/webclient/js-i2b2
exit_if_bad $? "Failed to copy i2b2loader.js into webclient." $LOG_FILE

#=========================================================================
# If we got this far, we must be successful (hopefully) ...
#=========================================================================
print_message "i2b2 web client install complete." $LOG_FILE
print_footer $( basename $0 ) $JOB_NAME $LOG_FILE