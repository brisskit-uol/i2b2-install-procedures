#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Tailors JBoss:
#   (i)   installs the axis2.war file
#   (ii)  sets JVM settings
#   (iii) configures ports
#
# Mandatory: the I2B2_INSTALL_PROCS_HOME environment variable to be set.
# Optional : the I2B2_INSTALL_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the install home.
#
# Pre-reqs:
#   JBoss installed
#   1-acquisitions.sh has been run at some point to acquire axis2.war
#   JBoss config settings reviewed (see config/jboss directory)
#
# USAGE: {script-file-name}.sh job-name
# Where: 
#   job-name is a suitable tag to group all jobs associated with the overall workflow
# Notes:
#   The job-name is used to create a work directory for the overall workflow; eg:
#   I2B2_INSTALL_PROCS_HOME/job-name
#   This work directory must already exist.
#
# Further tailoring can be achieved via the defaults.sh script.
#
# Question: Should this stop and start JBoss?
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
echo "About to install JBoss..."
echo ""
echo "   Please note detailed log messages are written to $LOG_FILE"
echo "   If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

JBOSS_INSTALL_DIRECTORY_NAME=$( basename $JBOSS_DOWNLOAD_PATH .tar.gz )

#
# Untar jboss file...
print_message "" $LOG_FILE
print_message "About to untar JBoss..." $LOG_FILE
tar -xvf $WORK_DIR/$ACQUISITIONS_DIRECTORY/$( basename $JBOSS_DOWNLOAD_PATH ) -C $I2B2_INSTALL_DIRECTORY >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to untar JBoss tar file to $I2B2_INSTALL_DIR/$JBOSS_INSTALL_DIRECTORY_NAME" $LOG_FILE

#
# Create a symbolic link to jboss...
ln -s $I2B2_INSTALL_DIRECTORY/$JBOSS_INSTALL_DIRECTORY_NAME $I2B2_INSTALL_DIRECTORY/jboss

#
# Overwrite the standalone.conf to set the correct JDK and appropriate memory settings for the java runtime...
print_message "" $LOG_FILE
print_message "Overwriting $JBOSS_HOME/bin/standalone.conf" $LOG_FILE
cp $I2B2_INSTALL_PROCS_HOME/config/jboss/standalone.conf $JBOSS_HOME/bin/
exit_if_bad $? "Could not overwrite $JBOSS_HOME/bin/standalone.conf" $LOG_FILE

#
# Overwrite the default server startup to set connectors to ports 9090 / 9009 ...
print_message "" $LOG_FILE
print_message "Overwriting $JBOSS_HOME/standalone/configuration/standalone.xml" $LOG_FILE
cp $I2B2_INSTALL_PROCS_HOME/config/jboss/standalone.xml $JBOSS_HOME/standalone/configuration/
exit_if_bad $? "Could not overwrite $JBOSS_HOME/standalone/configuration/standalone.xml" $LOG_FILE

#
# Install apache axis2 v1.6.2 ...
# (The artifact is a war file inside a zip file)
# The war file itself needs to be unzipped within directory JBOSS_HOME/standalone/deployments/i2b2.war
print_message "" $LOG_FILE
print_message "Installing Apache axis2-1.6.2" $LOG_FILE
AXIS_ZIP=$( basename $AXIS_WAR_DOWNLOAD_PATH )
mkdir $JBOSS_HOME/standalone/deployments/i2b2.war
exit_if_bad $? "Could not create directory $JBOSS_HOME/standalone/deployments/i2b2.war" $LOG_FILE
unzip $WORK_DIR/$ACQUISITIONS_DIRECTORY/$AXIS_ZIP axis2.war -d $JBOSS_HOME/standalone/deployments/i2b2.war >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to unzip/move axis2-1.6.2.war file to $JBOSS_HOME/standalone/deployments/i2b2.war" $LOG_FILE
unzip $JBOSS_HOME/standalone/deployments/i2b2.war/axis2.war -d $JBOSS_HOME/standalone/deployments/i2b2.war >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to expand the axis2.war file to $JBOSS_HOME/standalone/deployments/i2b2.war" $LOG_FILE
rm $JBOSS_HOME/standalone/deployments/i2b2.war/axis2.war >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to remove the archive war file axis2.war after expansion" $LOG_FILE
# Create the JBoss manual deploy file...
touch $JBOSS_HOME/standalone/deployments/i2b2.war.dodeploy
exit_if_bad $? "Failed to create the JBoss manual deploy file i2b2.war.dodeploy" $LOG_FILE
#=========================================================================
# If we got this far, we must be successful...
#=========================================================================
print_message "JBoss tailoring completed." $LOG_FILE
print_footer $( basename $0 ) $JOB_NAME $LOG_FILE