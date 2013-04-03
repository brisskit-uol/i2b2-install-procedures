#!/bin/bash
#-----------------------------------------------------------------------------------------------
# DROPS ALL SQL ARTIFACTS
#  
# This means it DROPS ALL SQL ARTIFACTS!!!
# For use in development only.
#
# Mandatory: 
#   (1) The I2B2_INSTALL_PROCS_HOME environment variable to be set.
#   (2) This script and associated files can only have been generated using the
#       development profile within a maven development build.
#       It SHOULD NOT BE POSSIBLE for this to be present in a production build.
#
# USAGE: DEVONLY-DROP-artifacts.sh please drop everything"
#   echo " Where:"
#   echo "   'please drop everything' is a simple safety barrier.
#
# Author: Jeff Lusted (jl99@leicester.ac.uk)
#-----------------------------------------------------------------------------------------------
source ../../../set.sh
source $I2B2_INSTALL_PROCS_HOME/bin/common/functions.sh
source $I2B2_INSTALL_PROCS_HOME/bin/common/setenv.sh

print_project_install_usage() {
   echo " USAGE: DEVONLY-DROP-artifacts.sh please drop everything"
   echo " Where:"
   echo "   'please drop everything' is a simple safety barrier."
}

#=======================================================================
# First, some basic checks...
#=======================================================================
#
# Check on the usage...
if [ ! $# -eq 3 ]
then
	echo "Error! Incorrect number of arguments."
	echo ""
	print_project_install_usage
	exit 1
fi

if [ "$1" != please -o "$2" != drop -o "$3" != everything ] 
then 
	echo "I will not drop everything unless you ask correctly!"
	echo "Goodbye."
	echo ""
	print_project_install_usage
	exit 1
fi

#======================================================================
#   Make sure the user has every opportunity to back out...
#======================================================================
echo "Please confirm you wish to drop everything: (yes/no) ?"
read answer

if [ "$answer" != yes ]
then
	echo "Drop not confirmed. Goodbye."
	exit 1
fi
	
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!!!!!!   In 10 seconds all SQL artifacts will be dropped    !!!!!!!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""
echo "To abort, press Ctrl C"
echo ""
sleep 1
echo "10"
sleep 1
echo "9"
sleep 1
echo "8"
sleep 1
echo "7"
sleep 1
echo "6"
sleep 1
echo "5"
sleep 1
echo "4"
sleep 1
echo "3"
sleep 1
echo "2"
sleep 1
echo "1"	
sleep 1 

#===========================================================================
# The real work starts...
#===========================================================================  

#================================================
# Drop the demodata for project 'demo'
#================================================
print_message ""
print_message "About to drop the demodata SQL artifacts for 'demo' project." 
                  
$ANT_HOME/bin/ant -propertyfile $I2B2_INSTALL_PROCS_HOME/config/config.properties \
                  -Dinstall.home=$I2B2_INSTALL_PROCS_HOME \
                  -f $I2B2_INSTALL_PROCS_HOME/ant/${DB_TYPE}/DEVONLY-DROP-artifacts.xml \
                  drop_demodata                 
exit_if_bad $? "Failed to drop demodata SQL artifacts for 'demo' project." 
print_message "Success! Dropped demodata SQL artifacts for 'demo' project."

#================================================
# Drop the metadata for project 'demo'
#================================================
print_message ""
print_message "About to drop the metadata SQL artifacts for 'demo' project." 
                  
$ANT_HOME/bin/ant -propertyfile $I2B2_INSTALL_PROCS_HOME/config/config.properties \
                  -Dinstall.home=$I2B2_INSTALL_PROCS_HOME \
                  -f $I2B2_INSTALL_PROCS_HOME/ant/${DB_TYPE}/DEVONLY-DROP-artifacts.xml \
                  drop_metadata                 
exit_if_bad $? "Failed to drop metadata SQL artifacts for 'demo' project." 
print_message "Success! Dropped metadata SQL artifacts for 'demo' project." 

#================================================
# Drop the workdata for project 'demo'
#================================================
print_message ""
print_message "About to drop the workdata SQL artifacts for 'demo' project." 
                  
$ANT_HOME/bin/ant -propertyfile $I2B2_INSTALL_PROCS_HOME/config/config.properties \
                  -Dinstall.home=$I2B2_INSTALL_PROCS_HOME \
                  -f $I2B2_INSTALL_PROCS_HOME/ant/${DB_TYPE}/DEVONLY-DROP-artifacts.xml \
                  drop_workdata                 
exit_if_bad $? "Failed to drop workdata SQL artifacts for 'demo' project." 
print_message "Success! Dropped workdata SQL artifacts for 'demo' project." 

#================================================
# Drop the hive SQL artifacts
#================================================
print_message ""
print_message "About to drop the hive SQL artifacts." 
                  
$ANT_HOME/bin/ant -propertyfile $I2B2_INSTALL_PROCS_HOME/config/config.properties \
                  -Dinstall.home=$I2B2_INSTALL_PROCS_HOME \
                  -f $I2B2_INSTALL_PROCS_HOME/ant/${DB_TYPE}/DEVONLY-DROP-artifacts.xml \
                  drop_i2b2hive                 
exit_if_bad $? "Failed to drop hive SQL artifacts." 
print_message "Success! Dropped hive SQL artifacts."

#================================================
# Drop the pm SQL artifacts 
#================================================
print_message ""
print_message "About to drop the PM SQL artifacts." 
                  
$ANT_HOME/bin/ant -propertyfile $I2B2_INSTALL_PROCS_HOME/config/config.properties \
                  -Dinstall.home=$I2B2_INSTALL_PROCS_HOME \
                  -f $I2B2_INSTALL_PROCS_HOME/ant/${DB_TYPE}/DEVONLY-DROP-artifacts.xml \
                  drop_i2b2pm                 
exit_if_bad $? "Failed to drop PM SQL artifacts." 
print_message "Success! Dropped PM SQL artifacts." 
#=========================================================================
# If we got this far, we must be successful (hopefully) ...
#=========================================================================
print_message "Goodbye."