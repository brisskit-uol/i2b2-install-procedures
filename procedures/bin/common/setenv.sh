#!/bin/bash
#
# Basic environment variables for i2b2
# 
# Invocation within another sh script should be:
# source $I2B2_INSTALL_PROCS_HOME/bin/common/setenv.sh
#
#-------------------------------------------------------------------
if [ -z $I2B2_INSTALL_DEFAULTS_DEFINED ]
then
	export I2B2_INSTALL_DEFAULTS_DEFINED=true	
	source $I2B2_INSTALL_PROCS_HOME/config/defaults.sh	
fi


