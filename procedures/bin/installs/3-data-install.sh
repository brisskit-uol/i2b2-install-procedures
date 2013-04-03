#!/bin/bash
#-----------------------------------------------------------------------------------------------
# Installs i2b2 core hive data plus data for the two demo projects. 
# Install means creating tables, procedures and loading data.
# In effect we have an i2b2 domain and one project set up here, but without the cell installs.
#
# Mandatory: the I2B2_INSTALL_PROCS_HOME environment variable to be set.
# Optional : the I2B2_INSTALL_WORKSPACE environment variable.
# The latter is an optional full path to a workspace area. If not set, defaults to a workspace
# within the install home.
#
# Pre-reqs:
#   JBoss installed and the following must have been run...
#   1-acquisitions.sh (establishes the work directory)
#   2-tailor-jboss.sh
#
# USAGE: {script-file-name}.sh job-name
# Where: 
#   job-name is a suitable tag to group all jobs associated with the overall workflow
# Notes:
#   The job-name is used to locate the work directory for the overall workflow; eg:
#   I2B2_INSTALL_PROCS_HOME/job-name
#   This work directory must already exist.
#
# Further tailoring can be achieved via the defaults.sh script.
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
# But if not, we use the default within the procedures home...
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
echo "About to install i2b2 domain data and demo data for the two demo projects..."
echo ""
echo "   Please note detailed log messages are written to $LOG_FILE"
echo "   If you want to see this during execution, try: tail -f $LOG_FILE"
echo ""

#
# Copy hive DB property files to required location
# and merge required substitution variables...
# (Used later in the Hive data installs and maybe before!)
merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/config/$DB_TYPE/data/hivedata-db.properties \
             $WORK_DIR/data/edu.harvard.i2b2.data/Release_1-5/NewInstall/Hivedata/db.properties     
exit_if_bad $? "Failed to merge properties into $WORK_DIR/data/edu.harvard.i2b2.data/Release_1-5/NewInstall/Hivedata/db.properties" $LOG_FILE  
 
#
# Copy PM DB property files to required location.
# and merge required substitution variables...
# (Used later in the PM data installs and maybe before!)
merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
            $I2B2_INSTALL_PROCS_HOME/config/$DB_TYPE/data/pmdata-db.properties \
            $WORK_DIR/data/edu.harvard.i2b2.data/Release_1-5/NewInstall/Pmdata/db.properties   
exit_if_bad $? "Failed to merge properties into $WORK_DIR/data/edu.harvard.i2b2.data/Release_1-5/NewInstall/Pmdata/db.properties" $LOG_FILE  

#================================================
# Install the metadata for project 'demo'
#================================================
print_message "" $LOG_FILE
print_message "About to create the metadata tables, indexes and sequences for 'demo' project." $LOG_FILE

#
# Copy config file for project 'demo' metadata...
# and merge required substitution values into it... 
merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/config/$DB_TYPE/data/metadata-db.properties \
             $WORK_DIR/$DATA_DIRECTORY/edu.harvard.i2b2.data/Release_1-5/NewInstall/Metadata/db.properties 
exit_if_bad $? "Failed to merge properties into $WORK_DIR/$DATA_DIRECTORY/edu.harvard.i2b2.data/Release_1-5/NewInstall/Metadata/db.properties" $LOG_FILE  
 
cd $WORK_DIR/$DATA_DIRECTORY/edu.harvard.i2b2.data/Release_1-5/NewInstall/Metadata
$ANT_HOME/bin/ant -f data_build.xml \
                  create_metadata_tables_release_1-5 \
                  >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to create metadata tables, indexes and sequences for 'demo' project." $LOG_FILE
print_message "Success! Created metadata tables, indexes and sequences for 'demo' project." $LOG_FILE

#
# Load the metadata for project 'demo'
print_message "" $LOG_FILE
print_message "About to load the metadata for 'demo' project. This will take some minutes." $LOG_FILE
$ANT_HOME/bin/ant -f data_build.xml \
                  db_metadata_load_data \
                  >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to load 'demo' project metadata." $LOG_FILE
print_message "Success! Metadata for 'demo' project loaded successfully." $LOG_FILE

#===============================================
# Install data for 'demo' project
#===============================================
print_message "" $LOG_FILE
print_message "About to create data tables, indexes and sequences for 'demo' project." $LOG_FILE

#
# Copy config file for 'demo' project
# and merge required substitution values into it... 
merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/config/$DB_TYPE/data/demodata-db.properties \
             $WORK_DIR/$DATA_DIRECTORY/edu.harvard.i2b2.data/Release_1-5/NewInstall/Demodata/db.properties
exit_if_bad $? "Failed to merge properties into $WORK_DIR/$DATA_DIRECTORY/edu.harvard.i2b2.data/Release_1-5/NewInstall/Demodata/db.properties" $LOG_FILE  

cd $WORK_DIR/$DATA_DIRECTORY/edu.harvard.i2b2.data/Release_1-5/NewInstall/Demodata
$ANT_HOME/bin/ant -f data_build.xml \
                  create_demodata_tables_release_1-5 \
                  >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to create data tables, indexes and sequences for 'demo' project" $LOG_FILE
print_message "Success! Created data tables, indexes and sequences for 'demo' project." $LOG_FILE

#
# Create the stored procedures
print_message "" $LOG_FILE
print_message "About to create stored procedures for 'demo' project." $LOG_FILE
$ANT_HOME/bin/ant -f data_build.xml \
                  create_procedures_release_1-5 \
                  >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to create stored procedures for 'demo' project." $LOG_FILE
print_message "Success! Created stored procedures for 'demo' project." $LOG_FILE      

#
# Load the data.
print_message "" $LOG_FILE
print_message "About to load the data for 'demo' project. This will take some minutes." $LOG_FILE
$ANT_HOME/bin/ant -f data_build.xml \
                  db_demodata_load_data \
                  >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to load data for 'demo' project." $LOG_FILE
print_message "Success! Data for 'demo' project loaded successfully." $LOG_FILE

#==========================================
# Install Workdata for 'demo' project
#==========================================
print_message "" $LOG_FILE
print_message "About to create workdata tables, indexes and sequences for 'demo' project." $LOG_FILE
#
# Copying config file for 'demo' project
# and merge required substitution values into it... 
merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/config/$DB_TYPE/data/workdata-db.properties \
             $WORK_DIR/$DATA_DIRECTORY/edu.harvard.i2b2.data/Release_1-5/NewInstall/Workdata/db.properties
exit_if_bad $? "Failed to merge properties into $WORK_DIR/$DATA_DIRECTORY/edu.harvard.i2b2.data/Release_1-5/NewInstall/Workdata/db.properties" $LOG_FILE  


cd $WORK_DIR/$DATA_DIRECTORY/edu.harvard.i2b2.data/Release_1-5/NewInstall/Workdata
$ANT_HOME/bin/ant -f data_build.xml \
                  create_workdata_tables_release_1-5 \
                   >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to create workdata tables, indexes and sequences for 'demo' project." $LOG_FILE
print_message "Success! Created workdata tables, indexes and sequences for 'demo' project." $LOG_FILE

#
# Load the data.
print_message ""
print_message "About to load the workdata for 'demo' project. This will take some minutes."
$ANT_HOME/bin/ant -f data_build.xml \
                  db_workdata_load_data  \
                  >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to load workdata for 'demo' project." $LOG_FILE
print_message "Success! Workdata for 'demo' project loaded successfully." $LOG_FILE

#==========================================
# Install Hivedata
#==========================================
print_message "" $LOG_FILE
print_message "About to create hive tables, indexes and sequences." $LOG_FILE

cd $WORK_DIR/$DATA_DIRECTORY/edu.harvard.i2b2.data/Release_1-5/NewInstall/Hivedata
$ANT_HOME/bin/ant -f data_build.xml \
                  create_hivedata_tables_release_1-5 \
                  >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to create hivedata tables, indexes and sequences" $LOG_FILE
print_message "Success! Created hivedata tables, indexes and sequences." $LOG_FILE

#
# Update hive data inserts with BRICCS specific i2b2 domain information...
NEWINSTALL=$WORK_DIR/$DATA_DIRECTORY/edu.harvard.i2b2.data/Release_1-5/NewInstall
merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/sql/$DB_TYPE/crc_db_lookup_${DB_TYPE}_insert_data.sql \
             $NEWINSTALL/Hivedata/scripts/crc_db_lookup_${DB_TYPE}_insert_data.sql
exit_if_bad $? "Failed to merge properties into $NEWINSTALL/Hivedata/scripts/crc_db_lookup_${DB_TYPE}_insert_data.sql" $LOG_FILE 

merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/sql/$DB_TYPE/ont_db_lookup_${DB_TYPE}_insert_data.sql \
             $NEWINSTALL/Hivedata/scripts/ont_db_lookup_${DB_TYPE}_insert_data.sql
exit_if_bad $? "Failed to merge properties into $NEWINSTALL/Hivedata/scripts/ont_db_lookup_${DB_TYPE}_insert_data.sql" $LOG_FILE
   
merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/sql/$DB_TYPE/work_db_lookup_${DB_TYPE}_insert_data.sql \
             $NEWINSTALL/Hivedata/scripts/work_db_lookup_${DB_TYPE}_insert_data.sql
exit_if_bad $? "Failed to merge properties into $NEWINSTALL/Hivedata/scripts/work_db_lookup_${DB_TYPE}_insert_data.sql" $LOG_FILE   
 
#
# Load the data.
print_message "" $LOG_FILE
print_message "About to load the hive data. This will take some minutes." $LOG_FILE
$ANT_HOME/bin/ant -f data_build.xml \
                  db_hivedata_load_data \
                  >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to load hivedata." $LOG_FILE
print_message "Success! Hivedata loaded successfully." $LOG_FILE

#==========================================
# Install Pmdata
#==========================================
print_message "" $LOG_FILE
print_message "About to create pm tables, indexes and sequences." $LOG_FILE

cd $WORK_DIR/$DATA_DIRECTORY/edu.harvard.i2b2.data/Release_1-5/NewInstall/Pmdata
$ANT_HOME/bin/ant -f data_build.xml \
                  create_pmdata_tables_release_1-5 \
                  >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to create pmdata tables, indexes and sequences" $LOG_FILE
print_message "Success! Created pmdata tables, indexes and sequences." $LOG_FILE

#
# Create the pm triggers
print_message "" $LOG_FILE 
print_message "About to create pm triggers." $LOG_FILE
$ANT_HOME/bin/ant -f data_build.xml \
                  create_triggers_release_1-5 \
                  >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to create pmdata triggers" $LOG_FILE
print_message "Success! Created pmdata triggers." $LOG_FILE

#
# Update pm data inserts with BRICCS specific i2b2 domain and web service information... 
merge_config $I2B2_INSTALL_PROCS_HOME/config/config.properties \
             $I2B2_INSTALL_PROCS_HOME/sql/pm_access_insert_data.sql \
             $NEWINSTALL/Pmdata/scripts/pm_access_insert_data.sql
exit_if_bad $? "Failed to merge properties into $NEWINSTALL/Pmdata/scripts/pm_access_insert_data.sql" $LOG_FILE

#
# Load the pm data.
print_message "" $LOG_FILE
print_message "About to load the pm data. This will take some minutes." $LOG_FILE
$ANT_HOME/bin/ant -f data_build.xml \
                  db_pmdata_load_data \
                  >>$LOG_FILE 2>>$LOG_FILE
exit_if_bad $? "Failed to load pmdata." $LOG_FILE
print_message "Success! Pmdata loaded successfully." $LOG_FILE

#=========================================================================
# If we got this far, we must be successful (hopefully) ...
#=========================================================================
print_message "Data install complete." $LOG_FILE
print_footer $( basename $0 ) $JOB_NAME $LOG_FILE