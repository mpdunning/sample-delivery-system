#!../../bin/linux-x86/sampleDelivery

< envPaths
epicsEnvSet( "ENGINEER", "Alex Wallace (awallace)" )
epicsEnvSet( "LOCATION", "MFX:R46:IOC:35" )
epicsEnvSet( "STREAM_PROTOCOL_PATH", "$(TOP)/sampleApp/protocol" )
epicsEnvSet( "IOCSH_PS1", "$(IOC)> " )
cd( "../.." )

# Run common startup commands for linux soft IOC's
< /reg/d/iocCommon/All/pre_linux.cmd

# Register all support components
dbLoadDatabase("dbd/sampleDelivery.dbd")
sampleDelivery_registerRecordDeviceDriver(pdbbase)

#Set some env variables
##Basic ioc stuff
epicsEnvSet( "LOC", "MFX")
epicsEnvSet( "SYS", "SDS") #Sample Delivery System
epicsEnvSet( "PLC", "plc-mfx-sds")
epicsEnvSet("EPICS_PV", "IOC:$(LOC):$(SYS):01")

< iocBoot/ioc-tst-sds/plcPorts.cmd

epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES","2000000",1)




####### Load record instances
dbLoadRecords( "db/iocAdmin.db",        "IOC=$(EPICS_PV)" )
dbLoadRecords( "db/save_restoreStatus.db",  "IOC=$(EPICS_PV)" )


#PLC modbus file
dbLoadRecords("db/m3-sds-modbus.db",	"DEV=$(LOC):$(SYS):")

#Auxiliary files
dbLoadRecords("db/sds-m2-sampleSelection.db",   "P=$(LOC):$(SYS),NUM=1")
dbLoadRecords("db/sds-m2-sampleSelection.db",   "P=$(LOC):$(SYS),NUM=2")
dbLoadRecords("db/sds-m2-regulatorLimiter.db", "DEV=$(LOC):$(SYS):REG:01")
dbLoadRecords("db/sds-m2-regulatorLimiter.db", "DEV=$(LOC):$(SYS):REG:02")

dbLoadRecords("db/sample_flow_accumulators.db", "DEV=$(LOC):$(SYS):SEL1,NUM=1")
dbLoadRecords("db/sample_flow_integration.db", "DEV=$(LOC):$(SYS):SEL1,FLOWMETER=$(LOC):$(SYS):SEL1:Flow,PUMP=$(LOC):LC20:$(SYS):FlowRate,NUM=1")

dbLoadRecords("db/sample_flow_accumulators.db", "DEV=$(LOC):$(SYS):SEL2,NUM=2")
dbLoadRecords("db/sample_flow_integration.db", "DEV=$(LOC):$(SYS):SEL2,FLOWMETER=$(LOC):$(SYS):SEL2:Flow,PUMP=$(LOC):LC20:$(SYS)B:FlowRate,NUM=2")


#Autosave
save_restoreSet_status_prefix("$(EPICS_PV)" )
save_restoreSet_IncompleteSetsOk( 1 )
save_restoreSet_DatedBackupFiles( 1 )

set_savefile_path( "$(IOC_DATA)/$(IOC)/autosave" )
set_requestfile_path( "$(TOP)/autosave" )

set_pass0_restoreFile( "$(IOC).sav" )
set_pass1_restoreFile( "$(IOC).sav" )
set_pass1_restoreFile( "sampleFlowAccumulators.sav")

# Initialize the IOC and start processing records
iocInit()

# Start autosave backups
create_monitor_set( "$(IOC).req", 30, "LOC=$(LOC), SYS=$(SYS)" )
create_monitor_set( "sampleFlowAccumulators.req", 1, "LOC=$(LOC), SYS=$(SYS)" )


# Initialize the IOC and start processing records
iocInit()


# All IOCs should dump some common info after initial startup.
< /reg/d/iocCommon/All/post_linux.cmd

