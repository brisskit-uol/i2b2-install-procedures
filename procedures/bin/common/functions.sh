#!/bin/bash
#
# Common Functions
#
# Invocation within another shell script should be
# source ${I2B2_INSTALL_PROCS_HOME}functions.sh
#
#----------------------------------------------------------------------------------------

#-----------------------------------------------------
# Common usage report.
# Most scripts have but one argument: the job name.
#-----------------------------------------------------
print_usage() {
   echo " USAGE: $0 job-name"
   echo " Where:"
   echo "   job-name is a suitable tag to group all jobs associated with the overall workflow"
   echo " Notes:"
   echo "   The job-name is used to create a working directory for the overall workflow; eg:"
   echo "   I2B2_INSTALL_PROCS_HOME/job-name"
   echo "   This working directory is created if it does not exist."
}

#----------------------------------------------------
# Check return code from the invocation of a command.
# If command complained (ie: not zero)
# Then echo message and exit.
# Param 1: return code
# Param 2: message
# Param 3: log file
#----------------------------------------------------
exit_if_bad()
{
  if [ "${1}" -ne "0" ]
  then
    echo "Error! ${2}"
    if [ $3 ]
    then
		echo "Error! ${2}" >> ${3}
	fi   
    # as a bonus, make our script exit with the right error code.
    exit ${1}
  fi
}

#----------------------------------------------------
# Check return code from the invocation of a command.
# If command does not complain (ie: zero)
# Then echo message and exit.
# Param 1: return code
# Param 2: message
# Param 3: log file
#----------------------------------------------------
exit_if_good()
{
  if [ "${1}" -eq "0" ]
  then
    echo "Error! ${2}"
    if [ $3 ]
    then
		echo "Error! ${2}" >> ${3}
	fi
    # as a bonus, make our script exit with the right error code.
    exit ${1}
  fi
}

#----------------------------------------------------
# Check return code from the invocation of a command.
# If command complained (ie: not zero)
# Then echo message but don't exit.
# Param 1: return code
# Param 2: message
# Param 3: log file
#----------------------------------------------------
comment_if_bad()
{
  # Function. Parameter 1 is the return code
  # Para. 2 is text to display on failure.
  if [ "${1}" -ne "0" ]
  then
    echo "Warning! ${2}"
    if [ $3 ]
    then
		echo "Warning! ${2}" >> ${3}
	fi
  fi
}

#----------------------------------------------------
# Print message to stdout and to log file
# ${1} : Message
# ${2} : Log file
# Could I simply pick up an export of log file???
#----------------------------------------------------
print_message()
{
	echo "${1}"
	if [ $2 ]
	then
		echo "${1}" >> ${2}
	fi
}

#----------------------------------------------------
# Print banner to stdout and to log file
# ${1} : Banner title
# ${2} : Job name
# ${3} : Log file
#----------------------------------------------------
print_banner()
{
	echo ""
	echo "" >> ${3}
	echo "*===================================================================================*"
	echo "*===================================================================================*" >> ${3}
	echo "*   Procedure: ${1}"
	echo "*   Procedure: ${1}" >> ${3}
	echo "*   Job: ${2}"
	echo "*   Job: ${2}" >> ${3}
	echo "*   Submitted by: `whoami` on `date`"
	echo "*   Submitted by: `whoami` on `date`" >> ${3}
	echo "*===================================================================================*"
	echo "*===================================================================================*" >> ${3}
}

#----------------------------------------------------
# Print procedure footer to stdout and to log file
# ${1} : Procedure
# ${2} : Job name
# ${3} : Log file
#----------------------------------------------------
print_footer()
{
	echo ""
	echo "" >> ${3}
	echo "*-----------------------------------------------------------------------------------*"
	echo "*-----------------------------------------------------------------------------------*" >> ${3}
	echo "*   Procedure: ${1}"
	echo "*   Procedure: ${1}" >> ${3}
	echo "*   Job: ${2}"
	echo "*   Job: ${2}" >> ${3}
	echo "*   Finished: `date`"
	echo "*   Finished: `date`" >> ${3}
	echo "*-----------------------------------------------------------------------------------*"
	echo "*-----------------------------------------------------------------------------------*" >> ${3}
	echo ""
	echo "" >> ${3}
}

#---------------------------------------------------------------------------
# Merges settings from a master config file into a client config file
# as a stream. It does not overwrite the client config file but streams
# the result to a target config file.
#
#
# Param 1: master config file
# Param 2: client config file
# Param 3: destination config file (the result is streamed here)
#---------------------------------------------------------------------------
merge_config()
{
  $JAVA_HOME/bin/java \
         -Dlog4j.configuration=file://$I2B2_INSTALL_PROCS_HOME/config/log4j.properties \
         -cp $(for i in $I2B2_INSTALL_PROCS_HOME/lib/*.jar ; do echo -n $i: ; done). \
         org.brisskit.config.ConfigMerger \
         -m=${1} \
         -c=${2} \
         1>${3} 2>>$LOG_FILE
}

#----------------------------------------------------------------------------
# Check if a package is installed.
# Note: without --all deb will generate an error message.
# Note: with --all deb has to process a lot more and is slow.
#----------------------------------------------------------------------------
installpackage()
    {
    local package=$1
    infolog "Checking system package [${package}]"
    local version=$(deb --query --all --queryformat '%{VERSION}' "${package}" 2> /dev/null)
    if [ -n "${version}" ]
    then
        infolog "Package [${package}][${version}] is installed"
    else
        infolog "Installing [${package}]"
        apt-get -y --force-yes install ${package}
    fi
    }

#-----------------------------------------------------------------------------
# Info logging.
#-----------------------------------------------------------------------------
infolog() {
    if [ -e "$LOG_FILE" ]
    then
        echo "INFO  : ${1}" | tee --append "$LOG_FILE"
    else
        echo "INFO  : ${1}"
    fi
    }


