#!/bin/bash
#
# Install script for i2b2 PM cell
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
# (1) The PM cell must be the first cell to be deployed...
#     This procedure takes advantage of that to do some prerequisites for all of i2b2,
#     viz: deploying the common package and the web client.
#
# (2) The web client is dependent on an http server running. This install assumes
#     it will be Apache and copies the web client admin source into /var/www/html
#     or similar as defined in the defaults.sh configuration settings.
#     This copy is done after the PM deploy. The http server should be running prior
#     to starting JBoss, so sensibly before this install is started.
#
# (3) Stops and starts JBoss. 
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
echo "About to install i2b2 PM cell..."
echo ""
echo "   Please note detailed log messages are written to $LOG_FILE"
echo "   If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

#
# Verify JBOSS is not running.
echo "Attempting to stop JBoss, if it is running."
$JBOSS_HOME/bin/shutdown.sh -S >/dev/null 2>/dev/null 
sleep 65

#
# Copy some build/config files to required locations 
# with substitution variables from the defaults config...
merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/config/$DB_TYPE/pm-cell/common-build.properties \
             $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.common/build.properties
exit_if_bad $? "Failed to merge properties into $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.common/build.properties" $LOG_FILE   

merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/config/$DB_TYPE/pm-cell/pm-build.properties \
             $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.pm/build.properties
exit_if_bad $? "Failed to merge properties into $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.pm/build.properties" $LOG_FILE  

merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/config/$DB_TYPE/pm-cell/pm-ds.xml \
             $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.pm/etc/jboss/pm-ds.xml
exit_if_bad $? "Failed to merge properties into $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.pm/etc/jboss/pm-ds.xml" $LOG_FILE 

#
# The web client config data needs BRICCS specific data folding into it beforehand...
merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/config/$DB_TYPE/pm-cell/i2b2_config_data.js \
             $WORK_DIR/$SOURCE_DIRECTORY/admin/i2b2_config_data.js
exit_if_bad $? "Failed to merge properties into $WORK_DIR/$SOURCE_DIRECTORY/admin/i2b2_config_data.js" $LOG_FILE  

#===================================
# Deploy the common package
#===================================
print_message "" $LOG_FILE
print_message "About to deploy the common package." $LOG_FILE

cd $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.common
$ANT_HOME/bin/ant clean dist deploy \
                  jboss_pre_deployment_setup \
                  >>$LOG_FILE 2>>$LOG_FILE 
exit_if_bad $? "Failed to install the common package." $LOG_FILE
print_message "Success! Common package installed." $LOG_FILE

#============================
# Deploy PM cell
#============================
print_message "" $LOG_FILE
print_message "About to deploy PM cell." $LOG_FILE

cd $WORK_DIR/$SOURCE_DIRECTORY/edu.harvard.i2b2.pm
$ANT_HOME/bin/ant -f master_build.xml \
                  clean build-all deploy \
                  >>$LOG_FILE 2>>$LOG_FILE 
exit_if_bad $? "Failed to deploy PM." $LOG_FILE
print_message "Success! PM deployed." $LOG_FILE

#===========================
# Install the WebClient
#===========================
print_message "" $LOG_FILE
print_message "About to deploy webclient. Assumes Apache Web Server already running." $LOG_FILE
mkdir -p $HTML_LOCATION
exit_if_bad $? "Failed to create directory $HTML_LOCATION" $LOG_FILE
cp -R $WORK_DIR/$SOURCE_DIRECTORY/admin $HTML_LOCATION
exit_if_bad $? "Failed to deploy i2b2 admin web client." $LOG_FILE
cp -R $WORK_DIR/$SOURCE_DIRECTORY/admin $HTML_LOCATION/main
exit_if_bad $? "Failed to deploy i2b2 general web client." $LOG_FILE
cd $HTML_LOCATION/main
sed 's/adminOnly: true,\r//' $HTML_LOCATION/admin/i2b2_config_data.js > $HTML_LOCATION/main/i2b2_config_data.js
exit_if_bad $? "Failed to alter settings in i2b2_config_data.js for general i2b2 web client." $LOG_FILE
print_message "Success! Web Client deployed." $LOG_FILE

#====================================
# START JBOSS (as a background task)
#====================================
echo ""
echo "Starting JBoss in the background..."
$JBOSS_HOME/bin/run.sh -b 0.0.0.0 >>$LOG_FILE 2>>$LOG_FILE &

sleep 65
echo ""
echo "Services should have started, but please check the install log or the JBoss logs."
echo "In a browser, use the following URL: $LIST_SERVICES_URL "
echo "to verify PMService is listed as active."

#=========================================================================
# If we got this far, we must be successful (hopefully) ...
#=========================================================================
print_message "PM install complete." $LOG_FILE
print_footer $( basename $0 ) $JOB_NAME $LOG_FILE