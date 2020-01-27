KMPVCBG ;SP/JML VSM background utility functions ;Jan 23, 2020@16:29
 ;;4.0;CAPACITY MANAGEMENT;**10001**;3/1/2018;Build 5
 ; Original Code by Department of Veterans Affairs in Public Domain
 ; *10001* Changes by (c) Sam Habiel 2018
 ; Licensed under Apache 2.0
 ; Look for *10001* for specific changes
 ;
MONLIST(KMPVML) ; Return list of configured Monitors
 K KMPVML
 N KMPVMKEY,KMPVIEN
 S KMPVMKEY=""
 F  S KMPVMKEY=$O(^KMPV(8969,"B",KMPVMKEY)) Q:KMPVMKEY=""  D
 .S KMPVIEN=$O(^KMPV(8969,"B",KMPVMKEY,""))
 .I KMPVIEN>0 S KMPVML(KMPVMKEY)=$P($G(^KMPV(8969,KMPVIEN,0)),"^",3)
 Q
 ;
STARTMON(KMPVMKEY,KMPVAUTO) ; Schedule transmission task in TaskMan and set ONOFF to ON
 N DA,DIE,DIR,DR,DTOUT,DUOUT,X,Y
 N KMPVEARR,KMPVERROR,KMPVNVAL,KMPVOVAL,KMPVRFREQ,KMPVOPT,KMPVSTAT,KMPVSTRT
 ;
 S KMPVAUTO=+$G(KMPVAUTO)
 ; Do not start monitor in test if ALLOW TEST SYSTEM is set to NO
 I $$PROD^KMPVCCFG()="Test",$$GETVAL^KMPVCCFG(KMPVMKEY,"ALLOW TEST SYSTEM",8969)="NO" D  Q
 .Q:KMPVAUTO=1
 .N DIR S DIR(0)="E"
 .S DIR("A",1)="",DIR("A",2)="Cannot start monitor in test environment"
 .S DIR("A",3)="'ALLOW TEST SYSTEM' is set to 'NO'",DIR("A")="Press any key to continue"
 .D ^DIR
 ;
 S KMPVOVAL=$$GETVAL^KMPVCCFG(KMPVMKEY,"ONOFF",8969)
 W ! K DIR S DIR(0)="Y",DIR("B")="No"
 S DIR("?")="Answer YES to start collecting "_KMPVMKEY_" data"
 S DIR("A")="Do you want to start "_KMPVMKEY_" collection?"
 I 'KMPVAUTO D ^DIR Q:$D(DTOUT)!$D(DUOUT)
 I ($G(Y)=1)!KMPVAUTO D
 .N KMPVOPT,KMPVSTRT,KMPVRFREQ,KMPVERROR,KMPVSTAT
 .S KMPVOPT=$$GETVAL^KMPVCCFG(KMPVMKEY,"TASKMAN OPTION",8969)
 .S KMPVSTRT=$$GETVAL^KMPVCCFG(KMPVMKEY,"TASKMAN SCHEDULE START",8969)
 .S KMPVRFREQ=$$GETVAL^KMPVCCFG(KMPVMKEY,"TASKMAN SCHEDULE FREQUENCY",8969)
 .I KMPVSTRT=""!(KMPVRFREQ="") D  Q
 ..Q:KMPVAUTO=1
 ..N DIR S DIR(0)="E"
 ..S DIR("A",1)="",DIR("A",2)="This is not configured correctly to be a repeating task."
 ..S DIR("A",3)="Check VSM Configuration related to this task. Task not started."
 ..S DIR("A")="Press any key to continue."
 ..D ^DIR
 .;
 .S KMPVSTAT=$$SETONE^KMPVCCFG(KMPVMKEY,"ONOFF","ON",.KMPVEARR)
 .; If VBEM set ^%ZTSCH("LOGRSRC")=1
 .I KMPVSTAT=0,KMPVMKEY="VBEM" S DIE=8989.3,DA=1,DR="300///YES" D ^DIE
 .; schedule background job 
 .D RESCH^XUTMOPT(KMPVOPT,KMPVSTRT,,KMPVRFREQ,"L",.KMPVERROR)
 .I $G(KMPVERROR)=-1 D  Q
 ..S KMPVSTAT=$$SETONE^KMPVCCFG(KMPVMKEY,"ONOFF","OFF",.KMPVEARR)
 ..Q:KMPVAUTO=1
 ..N DIR S DIR(0)="E"
 ..S DIR("A",1)="",DIR("A",2)="ERROR: "_KMPVMKEY_" BACKGROUND TASK NOT STARTED!",DIR("A")="Press any key to continue."
 ..I KMPVSTAT>0 S DIR("A",3)="Failed to set 'ONOFF' field back to 'OFF'"
 ..D ^DIR
 ;
 S KMPVNVAL=$$GETVAL^KMPVCCFG(KMPVMKEY,"ONOFF",8969)
 I KMPVOVAL'=KMPVNVAL D CFGMSG()
 Q
 ;
STOPMON(KMPVMKEY,KMPVAUTO) ;   Un-schedule transmission task in TaskMan and set ONOFF to OFF
 N DA,DIE,DIR,DR,DTOUT,DUOUT,X,Y
 N KMPVEARR,KMPVERROR,KMPVNVAL,KMPVOPT,KMPVOVAL,KMPVSTAT
 ;
 S KMPVAUTO=+$G(KMPVAUTO)
 S KMPVOVAL=$$GETVAL^KMPVCCFG(KMPVMKEY,"ONOFF",8969)
 S KMPVOPT=$$GETVAL^KMPVCCFG(KMPVMKEY,"TASKMAN OPTION",8969)
 W ! K DIR S DIR(0)="Y",DIR("B")="No"
 S DIR("?")="Answer YES to stop collecting "_KMPVMKEY_" data"
 S DIR("A")="Do you want to stop "_KMPVMKEY_" collection?"
 I 'KMPVAUTO D ^DIR Q:$D(DTOUT)!$D(DUOUT)
 I ($G(Y)=1)!KMPVAUTO D
 .S KMPVSTAT=$$SETONE^KMPVCCFG(KMPVMKEY,"ONOFF","OFF",.KMPVEARR)
 .; If VBEM set ^%ZTSCH("LOGRSRC")=1
 .I KMPVSTAT=0,KMPVMKEY="VBEM" S DIE=8989.3,DA=1,DR="300///NO" D ^DIE
 .; unschedule background job
 .D RESCH^XUTMOPT(KMPVOPT,"@",,,.KMPVERROR)
 .I $G(KMPVERROR) D  Q
 ..Q:KMPVAUTO=1
 ..N DIR S DIR(0)="E"
 ..S DIR("A",1)="",DIR("A",2)="ERROR: "_KMPVMKEY_" BACKGROUND TASK NOT STOPPED!",DIR("A")="Press any key to continue."
 ..S DIR("A",3)=$G(KMPVERROR)
 ..D ^DIR
 S KMPVNVAL=$$GETVAL^KMPVCCFG(KMPVMKEY,"ONOFF",8969)
 I KMPVOVAL'=KMPVNVAL D CFGMSG()
 Q
 ;
RESCH(KMPVMKEY,KMPVERR) ; Reschedule transmission task in TaskMan
 K KMPVERR
 N KMPVOPT,KMPVSTRT,KMPVRFREQ,KMPVERROR
 S KMPVOPT=$$GETVAL^KMPVCCFG(KMPVMKEY,"TASKMAN OPTION",8969)
 S KMPVSTRT=$$GETVAL^KMPVCCFG(KMPVMKEY,"TASKMAN SCHEDULE START",8969)
 S KMPVRFREQ=$$GETVAL^KMPVCCFG(KMPVMKEY,"TASKMAN SCHEDULE FREQUENCY",8969)
 D RESCH^XUTMOPT(KMPVOPT,KMPVSTRT,,KMPVRFREQ,"L",.KMPVERROR)
 I $D(KMPVERROR) D
 .S KMPVERR(1)="Failed to add "_KMPVOPT_" to 'OPTION SCHEDULING' file"
 .S KMPVERR(2)=KMPVERROR
 .S KMPVSTAT=$$SETONE^KMPVCCFG(KMPVMKEY,"ONOFF","OFF",.KMPVEARR)
 .I KMPVSTAT'=0 S KMPVERR(3)=$P(KMPVSTAT,"^",2),KMPVERR(4)="Failed to reset 'ONOFF' to 'OFF' after rescheduling failure."
 Q
 ;
DESCH(KMPVMKEY,KMPVERR) ; De-schedule transmission task in TaskMan
 S KMPVOPT=$$GETVAL^KMPVCCFG(KMPVMKEY,"TASKMAN OPTION",8969)
 D RESCH^XUTMOPT(KMPVOPT,"@",,,.KMPVERROR)
 I $D(KMPVERROR) D
 .S KMPVERR(1)="Failed to remove "_KMPVOPT_" from 'OPTION SCHEDULING' file"
 .S KMPVERR(2)=KMPVERROR
 Q
 ;
CANMESS(MTYPE,KMPVMKEY,KMPVSITE,KMPVD) ; Repeatable, configured informational mail messages
 N KMPVEMAIL,KMPVPROD,KMPVTEXT,XMSUB,XMTEXT,XMY,XMZ
 S KMPVPROD=$$PROD^KMPVCCFG()
 ;
 I MTYPE="JOBLATE" D
 .S KMPVTEXT($J,1)="Daily "_KMPVMKEY_" job behind for "_$P(KMPVSITE,"^",2)
 .S KMPVTEXT($J,2)="Number of days behind: "_KMPVD
 .S KMPVTEXT($J,3)="Message date: "_$ZD(+$H)
 .S XMSUB=KMPVMKEY_" DAILY JOB NOT RUN: "_$P(KMPVSITE,"^",2)_"  Production="_KMPVPROD
 I MTYPE="DELETE" D
 .S KMPVTEXT($J,1)="Purging "_KMPVMKEY_" data for "_$P(KMPVSITE,"^",2)
 .S KMPVTEXT($J,2)="Data purged for: "_KMPVD
 .S KMPVTEXT($J,3)="Message date: "_$ZD(+$H)
 .S XMSUB=KMPVMKEY_" PURGING DATA -- NOT TRANSMITTED: "_$P(KMPVSITE,"^",2)_"  Production="_KMPVPROD
 I MTYPE="TRANWARN" D
 .S KMPVTEXT($J,1)="Data transmissions of "_KMPVMKEY_" data late for "_$P(KMPVSITE,"^",2)
 .S KMPVTEXT($J,2)="Message date: "_$ZD(+$H)
 .S XMSUB=KMPVMKEY_" Late Transmission Warning: "_$P(KMPVSITE,"^",2)_"  Production="_KMPVPROD
 I MTYPE="FAILTRAN" D
 .S KMPVTEXT($J,1)="Failed transmission for "_$P(KMPVSITE,"^",2)
 .S KMPVTEXT($J,2)="Collection date: "_KMPVD
 .S KMPVTEXT($J,3)="Message date: "_$ZD(+$H)
 .S XMSUB=KMPVMKEY_" FAILED "_KMPVMKEY_" TRANSMISSION: "_$P(KMPVSITE,"^",2)_"  "_KMPVD_"  Production="_KMPVPROD
 I MTYPE="KILL" D
 .S KMPVTEXT($J,1)="All data deleted at "_$P(KMPVSITE,"^",2)_" for "_KMPVMKEY
 .S KMPVTEXT($J,2)="Username: "_$$USERNAME^KMPVCCFG(DUZ)
 .S KMPVTEXT($J,3)="Message date: "_$ZD(+$H)
 .S XMSUB="EMERGENCY DATA DELETION AT "_$P(KMPVSITE,"^",2)_"  "_KMPVMKEY_"  Production="_KMPVPROD
 Q:$D(XMSUB)=""
 S XMTEXT="KMPVTEXT("_$J_","
 S KMPVEMAIL=$$GETVAL^KMPVCCFG(KMPVMKEY,"NATIONAL SUPPORT EMAIL ADDRESS",8969) I KMPVEMAIL'="" S XMY(KMPVEMAIL)=""
 S KMPVEMAIL=$$GETVAL^KMPVCCFG(KMPVMKEY,"LOCAL SUPPORT EMAIL ADDRESS",8969) I KMPVEMAIL'="" S XMY(KMPVEMAIL)=""
 D ^XMD
 Q
 ;
SUPMSG(KMPVTEXT) ;  Send email to local/national support mail groups
 N KMPVEMAIL,KMPVPROD,XMSUB,XMTEXT,XMY,XMZ
 S KMPVPROD=$$PROD^KMPVCCFG()
 ;
 S XMSUB=KMPVTEXT_" Prod="_KMPVPROD
 S XMTEXT="KMPVTEXT("
 S KMPVMKEY=""
 F  S KMPVMKEY=$O(^KMPV(8969,"B",KMPVMKEY)) Q:KMPVMKEY=""  D
 .S KMPVEMAIL=$$GETVAL^KMPVCCFG(KMPVMKEY,"LOCAL SUPPORT EMAIL ADDRESS",8969) I KMPVEMAIL'="" S XMY(KMPVEMAIL)=""
 .S KMPVEMAIL=$$GETVAL^KMPVCCFG(KMPVMKEY,"NATIONAL SUPPORT EMAIL ADDRESS",8969) I KMPVEMAIL'="" S XMY(KMPVEMAIL)=""
 D ^XMD
 Q
 ;
DBAMSG(KMPVTEXT) ;  Send email to national support mail groups
 N KMPVEMAIL,KMPVPROD,XMSUB,XMTEXT,XMY,XMZ
 S KMPVPROD=$$PROD^KMPVCCFG()
 ;
 S XMSUB=KMPVTEXT_" Prod="_KMPVPROD
 S XMTEXT="KMPVTEXT("
 S KMPVMKEY=""
 F  S KMPVMKEY=$O(^KMPV(8969,"B",KMPVMKEY)) Q:KMPVMKEY=""  D
 .S KMPVEMAIL=$$GETVAL^KMPVCCFG(KMPVMKEY,"NATIONAL SUPPORT EMAIL ADDRESS",8969) I KMPVEMAIL'="" S XMY(KMPVEMAIL)=""
 D ^XMD
 Q
 ;
CFGMSG(KMPVRQNAM) ;  Send configuration data to update Location Table at National VSM Database
 N KMPVDOM,KMPVEMAIL,KMPVLN,KMPVMKEY,KMPVPROD,KMPVSINF,KMPVSITE,KMPVUP,KMPVUPCFG,XMSUB,XMTEXT,XMY,XMZ
 S KMPVPROD=$$PROD^KMPVCCFG()
 ;
 I $G(KMPVRQNAM)="" S KMPVRQNAM=$$USERNAME^KMPVCCFG($G(DUZ))
 S KMPVSITE=$$SITE^VASITE ;IA 10112
 S KMPVLN=1
 S KMPVUP="KMP CFG"
 S KMPVDOM=$P($$NETNAME^XMXUTIL(.5),"@",2) ;IA 2734
 S KMPVSINF=$$SITEINFO^KMPVCCFG()
 S KMPVUP(KMPVLN)="SYSTEM ID="_KMPVSINF,KMPVLN=KMPVLN+1
 S KMPVUP(KMPVLN)="UPDATE CONFIG="_+$H_"^"_KMPVRQNAM,KMPVLN=KMPVLN+1
 S KMPVUP(KMPVLN)="SYSTEM CONFIG="_$$SYSCFG^KMPVCCFG(),KMPVLN=KMPVLN+1
 S KMPVMKEY=""
 F  S KMPVMKEY=$O(^KMPV(8969,"B",KMPVMKEY)) Q:KMPVMKEY=""  D
 .S KMPVUP(KMPVLN)="MONITOR CONFIG="_$$CFGSTR^KMPVCCFG(KMPVMKEY),KMPVLN=KMPVLN+1
 S XMSUB=KMPVUP,XMTEXT="KMPVUP("
 S KMPVMKEY=""
 F  S KMPVMKEY=$O(^KMPV(8969,"B",KMPVMKEY)) Q:KMPVMKEY=""  D
 .S KMPVEMAIL=$$GETVAL^KMPVCCFG(KMPVMKEY,"VSM CFG EMAIL ADDRESS",8969) I KMPVEMAIL'="" S XMY(KMPVEMAIL)=""
 D ^XMD
 Q
 ;
PURGEDLY(KMPVMKEY) ; Purge any data older than VSM CONFIURATION file specifies
 N KMPVCURH,KMPVH,KMPVKEEP
 S KMPVH="",KMPVCURH=+$H,KMPVKEEP=$$GETVAL^KMPVCCFG(KMPVMKEY,"DAYS TO KEEP DATA",8969)
 F  S KMPVH=$O(^KMPTMP("KMPV",KMPVMKEY,"DLY",KMPVH)) Q:KMPVH=""  D
 .I (KMPVCURH-KMPVH)>KMPVKEEP K ^KMPTMP("KMPV",KMPVMKEY,"DLY",KMPVH)
 I '$$VA^KMPVLOG D DELLOG^KMPVLOG("KMPV",KMPVMKEY,KMPVKEEP)
 Q
 ;
KMPVTSK(KMPVNSP) ; CHECK CREATE OR RESUME KMPVRUN TASK IN CACHE TASKMGR
 N I,KMPVMSG,KMPVNSPE,KMPVROLS,KMPVTASK,KMPVTFLG,KMPVTSK,KMPVTSKS
 ;
 I ^%ZOSF("OS")["GT.M" D GTMTSK QUIT  ; *10001* GTM Support
 ;
 ; Start: only in KMPVCBG version - comment out for ZSTU
 S KMPVROLS=$ROLES
 I (KMPVROLS'["%All")&(KMPVROLS'["%Manager") D  Q
 .W !,"You must have either the %Manager or the %All Role",!
 ; End: only in KMPV version ----
 ;
 I '$D(KMPVNSP)||'##Class(%SYS.Namespace).Exists(KMPVNSP) S KMPVNSP=$NAMESPACE
 S KMPVTSK="KMPVRUN"
 I KMPVNSP'=$NAMESPACE S KMPVTSK=KMPVTSK_"_"_KMPVNSP
 S KMPVMSG="CHECKING KMPV SETUP IN "_KMPVNSP_" NAMESPACE..."
 W !,KMPVMSG,!!
 DO ##class(%SYS.System).WriteToConsoleLog("ZSTU: "_KMPVMSG,0,0)
 ; Start: only in ZSTU version - comment out for KMPVCBG
 ;I '$$EXIST^%R("KMPVRUN",KMPVNSP) D  Q "VSMRUN Check Complete... No Routine."
 ;.S KMPVMSG(1)="KMPVRUN routine does not exist in "_KMPVNSP_" namespace."
 ;.S KMPVMSG(2)="Please verify that patch KMPV*1.0*0 has been successfully installed."
 ;.F I=1:1:2 W !,KMPVMSG(I) DO ##class(%SYS.System).WriteToConsoleLog("ZSTU: "_KMPVMSG(I),0,0)
 ;.W !
 ; End: only in ZSTU version ----
 S KMPVTFLG=0
 S KMPVTSKS=##class(%ResultSet).%New("%SYS.TaskSuper.TaskListDetail")
 S KMPVSTAT=KMPVTSKS.Execute()
 D DisplayError^%apiOBJ(KMPVSTAT)
 while KMPVTSKS.Next() {
 if (KMPVTSKS.GetDataByName("Task Name")=KMPVTSK) {
  set KMPVTID=KMPVTSKS.GetDataByName("ID")
  set KMPVTRUN=KMPVTSKS.GetDataByName("Next Scheduled Date")_" at "_KMPVTSKS.GetDataByName("Next Scheduled Time")
  if KMPVTSKS.GetDataByName("Suspended")'="" {
   do ##class(%SYS.Task).Resume(KMPVTID)
   S KMPVMSG=KMPVTSK_" Task #"_KMPVTID_" Exists and Resumed to Run at "_KMPVTRUN
  } Else {
   S KMPVMSG=KMPVTSK_" Task #"_KMPVTID_" Exists and Scheduled to Run at "_KMPVTRUN
   }
  set KMPVTFLG=1
  W !,KMPVMSG
  DO ##class(%SYS.System).WriteToConsoleLog("ZSTU: "_KMPVMSG,0,0)
  quit
   }
 }
 ;
 ;create task if it doesn't exist
 I 'KMPVTFLG D
 .S KMPVTASK=##Class(%SYS.Task).%New()
 .S KMPVTASK.Name=KMPVTSK
 .S KMPVTASK.Description = "Start VSM Collection Drivers"
 .S KMPVTASK.NameSpace=KMPVNSP
 .S KMPVTASK.TaskClass="%SYS.Task.RunLegacyTask"
 .S KMPVTASK.Settings=$lb("ExecuteCode","D RUN^KMPVRUN")
 .S KMPVTASK.RunAsUser = "_SYSTEM"
 .S KMPVTASK.Priority=0
 .S KMPVTASK.StartDate = $p($h,",",1)+1
 .S KMPVTASK.DailyFrequency=0 ;task.DailyFrequencyDisplayToLogical("Once")
 .S KMPVTASK.DailyFrequencyTime=""
 .S KMPVTASK.DailyIncrement=""
 .S KMPVTASK.DailyStartTime=60
 .S KMPVTASK.Expires=0
 .S KMPVTASK.DailyEndTime=""
 .S KMPVTASK.RescheduleOnStart=1
 .S KMPVSTAT=KMPVTASK.%Save()
 .I $System.Status.IsError(KMPVSTAT) D  Q
 ..S KMPVMSG(1)="Error #"_$System.Status.GetErrorCodes(KMPVSTAT)
 ..S KMPVMSG(2)=$System.Status.GetOneStatusText(KMPVSTAT,1)
 ..S KMPVMSG(3)="Failed to Create and Schedule Task "_KMPVTSK_" in Cache Task Manager"
 ..F I=1:1:3 W !,KMPVMSG(I) DO ##class(%SYS.System).WriteToConsoleLog("ZSTU: "_KMPVMSG(I),0,1)
 .S KMPVMSG="Created and scheduled Task "_KMPVTSK_" in Cache Task Manager"
 .W !,KMPVMSG DO ##class(%SYS.System).WriteToConsoleLog("ZSTU: "_KMPVMSG,0,0)
 Q
 ;
GTMTSK ; [Private] GTM Task support
 W !
 W "GT.M/YottaDB SUPPORT",!!
 W "For the VistA system monitor to work, you need to run a cron job every night",!
 W "The cron job needs to source environment variables and then run RUN^KMPVRUN",!
 W "Here's an example crontab: ",!
 W "10 0 * * * . /var/db/foia201805/env.vista; mumps -r RUN^KMPVRUN",!
 QUIT
