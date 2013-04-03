#!/bin/bash
#--------------------------------------------------------------------------------------------
source $I2B2_INSTALL_PROCS_HOME/bin/common/setenv.sh
source $I2B2_INSTALL_PROCS_HOME/bin/common/functions.sh

#
# Establish a log file for the job...
WORK_DIR=$I2B2_INSTALL_WORKSPACE/$JOB_NAME
LOG_FILE=$WORK_DIR/$JOB_LOG_NAME

#====================================
# START JBOSS (as a background task)
#====================================
print_message "" $LOG_FILE
print_message "Starting JBoss in the background..." $LOG_FILE
$JBOSS_HOME/bin/run.sh -b 0.0.0.0 >>$LOG_FILE 2>>$LOG_FILE &

sleep 35
echo ""
echo "Services should have started, but please check the install log or the JBoss logs."
echo "In a browser, use the following URL: $LIST_SERVICES_URL"

