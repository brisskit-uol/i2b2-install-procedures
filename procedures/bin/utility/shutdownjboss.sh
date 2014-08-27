#!/bin/bash
#--------------------------------------------------------------------------------------------
source $I2B2_INSTALL_PROCS_HOME/bin/common/setenv.sh
source $I2B2_INSTALL_PROCS_HOME/bin/common/functions.sh

#
# Establish a log file for the job...
WORK_DIR=$I2B2_INSTALL_WORKSPACE/$JOB_NAME
LOG_FILE=$WORK_DIR/$JOB_LOG_NAME

#====================================
# STOP JBOSS
#====================================
print_message "" $LOG_FILE
print_message "Attempting to stop JBoss, if it is running..." $LOG_FILE
$JBOSS_HOME/bin/jboss-cli.sh --connect :shutdown >>$LOG_FILE 2>>$LOG_FILE

sleep 15
echo ""
echo "Services should have stopped, but please check the job log or the JBoss logs."

