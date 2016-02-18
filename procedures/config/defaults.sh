#!/bin/bash
#
# Default settings used by scripts within the bin directory
# 
#-------------------------------------------------------------------

# Log file name:
export JOB_LOG_NAME=job.log

# Database: either oracle, sqlserver or postgresql
export DB_TYPE=postgresql

# Name of directory to hold archives of source, 
# demo data and others acquired from elsewhere
export ACQUISITIONS_DIRECTORY=acquisitions

# Name of directory to hold official i2b2 source 
# (Will be downloaded here)
export SOURCE_DIRECTORY=source

# Name of directory to hold data for the i2b2 hive and its demo system
# (Will be downloaded here)
export DATA_DIRECTORY=data

#
# Flag to switch off the multiple shutting down and starting up of JBOSS
# (Default setting is 'false'. That is, multiple startups will occur).
export DELAY_JBOSS_STOPSTART=false

# We need a user and password for wget to maven repo
export MVN_DEPLOY_USER=readonly
export MVN_DEPLOY_PASSWORD=readonly...

# Acquisition paths.
# Intermediate environment variable BMN points to the Brisskit Maven instance of Nexus
BMN=https://maven.brisskit.le.ac.uk:443/nexus/content/repositories
export JDK_DOWNLOAD_PATH=${BMN}/thirdparty/oracle/jdk/jdk/7u17-linux/jdk-7u17-linux-x64.tar.gz
export ANT_DOWNLOAD_PATH=${BMN}/thirdparty/apache/ant/apache-ant/1.8.4/apache-ant-1.8.4-bin.zip
export JBOSS_DOWNLOAD_PATH=${BMN}/thirdparty/jboss/jboss-server/jboss-as/7.1.1.Final/jboss-as-7.1.1.Final.tar.gz
export I2B2_SOURCE_DOWNLOAD_PATH=${BMN}/thirdparty/i2b2/i2b2core-src/1701-brisskit-1.0/i2b2core-src-1701-brisskit-1.0.zip
export I2B2_DATA_DOWNLOAD_PATH=${BMN}/thirdparty/i2b2/i2b2createdb/1701-brisskit-1.0/i2b2createdb-1701-brisskit-1.0.zip
export AXIS_WAR_DOWNLOAD_PATH=${BMN}/thirdparty/axis/axis2/1.6.2/axis2-1.6.2-war.zip
export I2B2_INTEGRATION_WS_DOWNLOAD_PATH=${BMN}/releases/org/brisskit/app/i2b2/i2b2WS/1.0-RC1/i2b2WS-1.0-RC2.war
## NB: admin procedures are still under development for Postgresql
export I2B2_ADMIN_PROCEDURES_DOWNLOAD_PATH=${BMN}/snapshots/org/brisskit/app/i2b2/i2b2-1.7-admin-procedures/1.0-development-SNAPSHOT/i2b2-1.7-admin-procedures-1.0-development-20140318.160958-1.zip
export I2B2_CIVI_EXPORT_PLUGIN_DOWNLOAD_PATH=${BMN}/releases/org/brisskit/app/i2b2/i2b2-civi-plugin/1.0-RC1/i2b2-civi-plugin-1.0-RC1.zip
#
# OS A/C user for integration purposes.
# This user is created.
export SSH_INTEGRATION_USER=integration

# Directory Names for some of the installs...
export JDK_DIRECTORY_NAME=jdk1.7.0_17
export ANT_DIRECTORY_NAME=apache-ant-1.8.4

# Directory used by the integration web service to hold PDO files...
export PDO_DIRECTORY=$I2B2_INSTALL_DIRECTORY/upload-pdo

# Location for installation of apache web server files (used for i2b2 web client)
export HTML_LOCATION=/var/www/i2b2

#
# URL to check i2b2 services are up and available
# This should be a full address. Don't use localhost.
# The port number depends upon whether you have encryption set up.
# For encryption use 8443. If no encryption, use 8080
export LIST_SERVICES_URL=https://YOUR_SERVER_HERE:8080/i2b2/services/listServices

# Location of the i2b2 file repo cell (will be created by the install)
export FILE_REPO_LOCATION=/var/local/brisskit/i2b2/FRC

# Custom space for the install workspace (if required)
# If not defined, defaults to I2B2_INSTALL_PROCS_HOME/work
#export I2B2_INSTALL_WORKSPACE=?

#---------------------------------------------------------------------------------
# Java, Ant and JBoss home directories...
#---------------------------------------------------------------------------------
export JBOSS_HOME=$I2B2_INSTALL_DIRECTORY/jboss
export ANT_HOME=$I2B2_INSTALL_DIRECTORY/ant
export JAVA_HOME=$I2B2_INSTALL_DIRECTORY/jdk
