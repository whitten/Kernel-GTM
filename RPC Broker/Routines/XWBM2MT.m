XWBM2MT ;OIFO-Oakland/REM - M2M Broker Example ;05/16/2002  14:09
 ;;1.1;RPC BROKER;**28**;Mar 28, 1997
 ;
 QUIT
 ;
EN(CONTX,RPCN) ;Entry point to hard code IP,PORT,AV
 S IP="127.0.0.1",PORT=9800,AV="QQQQ11;11ZZZZ.."
 D EN1(CONTX,RPCN,PORT,IP,AV)
 Q
 ;
EN1(CONTX,RPCN,PORT,IP,AV) ;
 N I
 ;Entry point that passes in needed parameters.  If use this entry point,
 ; need to set up params first.
 ;CONTX - Name of context
 ;RPCN - RPC name
 ;PORT - port number
 ;IP - IP address
 ;AV - access/verify codes
 ;XWBOPEN - set this flag before call to keep connection open after call.
 K REQ,STATE,RPC
 S U="^" I $G(DUZ)'>0 W !,"Please Call XUP first!" Q
 D HOME^%ZIS U IO
 W !!,"Test a M2M call to ",CONTX," context."
 D OPEN(PORT,IP,AV)
 I XWBSTATE("M2M","OPEN")=0 D HOME^%ZIS U IO W !,"Didn't get port open or AV failed." Q
 I '$$SETCONTX^XWBM2MC(CONTX) D HOME^%ZIS U IO W !,"Didn't get Context" G EXIT
 ;This code is run if called from EN3
 I $G(RMFLAG)=1 D
 .D CLEARP
 .D SETPARAM(1,"STRING","RAUL TEST")
 D HOME^%ZIS U IO
 W !,"Call ",RPCN," - RPC."
 I '$$CALLRPC^XWBM2MC(RPCN,"REQ",1) D HOME^%ZIS U IO W !,"Could not run RPC."
 W !,"Result: " F I=1:1 Q:'$D(REQ(I))  W !,REQ(I)
 W !
 K RMFLAG
 I $G(XWBOPEN)=1 Q  ;flag to quit and keep connection open
 ;
EXIT D CLOSE
 Q
 ;
EN2 ;Entry point that hard sets IP,PORT,AV,CONTEXT,RPC.
 ;RMFLAG - if RMGLAG=1, it will set PARAM in EN1. 
 N IP,PORT,AV,CONTX,RPCN,RMFLAG
 S RMFLAG=1
 ;S IP="127.0.0.1",PORT="9800",AV="2287CTD;11ZZZZ.." ;BayPines Cache
 S IP="127.0.0.1",PORT=9800,AV="QQQQ11;11ZZZZ.."
 S CONTX="XWB BROKER EXAMPLE",RPCN="XWB EXAMPLE ECHO STRING"
 D EN1(CONTX,RPCN,PORT,IP,AV)
 Q
 ;
EN3(VAL) ;Just runs RPC; need to OPEN, SETCONTX then CLOSE.  Or just call after 
 ; connection has been done. **ONLY WORKS FOR TESTING IN DEV,XWB**
 N STR,ROOT,RPC,RES
 S ^TMP("XWBM2MTEST",$J,"TYPE")="STRING"
 S ^TMP("XWBM2MTEST",$J,"VALUE")=VAL
 S ROOT=$NA(^TMP("XWBM2MTEST",$J))
 I '$$PARAM^XWBM2MC(1,ROOT) W !,"PARAM failed." Q 0
 S RPC="ZZRM TEST RPC",RES="RESPONSE"
 I '$$CALLRPC^XWBM2MC(RPC,RES,0) Q 0  ;D HOME^%ZIS U IO W !,"Could not run RPC."
 K ^TMP("XWBM2MTEST")
 Q 1
 ;
ECHOSTR ;Example of Echo String
 N XWBSTR,XWBIP,XWBPORT,XWBAV,Y
 S XWBIP="",XWBPORT="",XWBAV=""
 K DIR S DIR(0)="FAU^1:50",DIR("A")="Enter String: ",DIR("B")="TEST STRING"
 D ^DIR I $D(DIRUT) Q
 S XWBSTR=$$CHARCHK^XWBUTL(Y)
 D CLEARP
 D SETPARAM(1,"STRING",XWBSTR)
 I $G(XWBFLAG) D EN("XWB BROKER EXAMPLE","XWB EXAMPLE ECHO STRING") K XWBFLAG Q
 D USERIP Q:$G(XWBQUIT) 
 D EN1("XWB BROKER EXAMPLE","XWB EXAMPLE ECHO STRING",XWBPORT,XWBIP,XWBAV)
 D CLEAN
 Q
 ;
WP ;Example of WP
 N XWBSTR,XWBIP,XWBPORT,XWBAV
 S XWBIP="",XWBPORT="",XWBAV=""
 D CLEARP
 I $G(XWBFLAG) D EN("XWB BROKER EXAMPLE","XWB EXAMPLE WPTEXT") K XWBFLAG Q
 D USERIP Q:$G(XWBQUIT)
 D EN1("XWB BROKER EXAMPLE","XWB EXAMPLE WPTEXT",XWBPORT,XWBIP,XWBAV)
 D CLEAN
 Q
 ;
LARRY ;Example of passing Array (mult).
 N XWBIP,XWBPORT,XWBAV
 S XWBIP="",XWBPORT="",XWBAV=""
 D CLEARP
 S XWBPARMS("PARAMS",1,"TYPE")="ARRAY"
 S XWBPARMS("PARAMS",1,"VALUE","Raul")="Programmer"
 S XWBPARMS("PARAMS",1,"VALUE","Susan")="Tech Writter"
 S XWBPARMS("PARAMS",1,"VALUE","Dan")="Project Mgr"
 I $G(XWBFLAG) D EN("XWB BROKER EXAMPLE","XWB M2M EXAMPLE LARRY") K XWBFLAG Q
 D USERIP Q:$G(XWBQUIT)
 D EN1("XWB BROKER EXAMPLE","XWB M2M EXAMPLE LARRY",XWBPORT,XWBIP,XWBAV)
 D CLEAN
 Q
 ;
LARRYRP(XWBY,XWBARR,XWBSTR) ;Remote procedure for local array
 NEW XWBX,XWBLINE
 ;
 SET XWBLINE=0
 I $G(XWBSTR)'="" S XWBY(1)=$G(XWBSTR) S XWBLINE=1
 SET XWBX="" FOR  SET XWBX=$O(XWBARR(XWBX)) QUIT:XWBX=""  DO
 .S XWBLINE=XWBLINE+1
 .S XWBY(XWBLINE)=XWBX_" / "_XWBARR(XWBX)
 Q
 ;
LARRSTR ;Example of passing Array (mult) and String.
 N XWBIP,XWBPORT,XWBAV
 S XWBIP="",XWBPORT="",XWBAV=""
 D CLEARP
 S XWBPARMS("PARAMS",1,"TYPE")="ARRAY"
 S XWBPARMS("PARAMS",1,"VALUE","Raul")="Programmer"
 S XWBPARMS("PARAMS",1,"VALUE","Susan")="Tech Writter"
 S XWBPARMS("PARAMS",1,"VALUE","Dan")="Project Mgr"
 S XWBPARMS("PARAMS",2,"TYPE")="STRING"
 S XWBPARMS("PARAMS",2,"VALUE")="String and Array (MULT) TEST"
 I $G(XWBFLAG) D EN("XWB BROKER EXAMPLE","XWB M2M EXAMPLE LARRY") K XWBFLAG Q
 D USERIP Q:$G(XWBQUIT)
 D EN1("XWB BROKER EXAMPLE","XWB M2M EXAMPLE LARRY",XWBPORT,XWBIP,XWBAV)
 D CLEAN
 Q
 ;
REF ;Example of passing a value by reference
 N XWBREF,Y,XWBSTR,XWBIP,XWBPORT,XWBAV
 S XWBIP="",XWBPORT="",XWBAV=""
 K DIR S DIR(0)="FAU^1:50",DIR("A")="Enter Reference Value: ",DIR("B")="DT"
 D ^DIR I $D(DIRUT) Q
 S XWBREF=$$CHARCHK^XWBUTL(Y)
 D CLEARP
 D SETPARAM(1,"REF",XWBREF)
 I $G(XWBFLAG) D EN("XWB BROKER EXAMPLE","XWB M2M EXAMPLE REF") K XWBFLAG Q
 D USERIP Q:$G(XWBQUIT)
 D EN1("XWB BROKER EXAMPLE","XWB M2M EXAMPLE REF",XWBPORT,XWBIP,XWBAV)
 D CLEAN
 Q
 ;
REFRP(RET,PARAM) ;Remote procedure for value passed by reference
 S RET(0)=PARAM
 Q
 ;
USERIP ;Get IP,Port,AV from user for connection.
 N Y
 S XWBQUIT=0
 K DIR S DIR(0)="FAU^1:50",DIR("A")="Enter IP: ",DIR("B")="127.0.0.1"
 D ^DIR I $D(DIRUT) S XWBQUIT=1 Q
 S XWBIP=Y
 K DIR S DIR(0)="FAU^1:50",DIR("A")="Enter PORT: ",DIR("B")="9800"
 D ^DIR I $D(DIRUT) S XWBQUIT=1 Q
 S XWBPORT=Y
 K DIR S DIR(0)="FAU^1:50",DIR("A")="Enter AV: ",DIR("?")="e.g. Smith;11PASSWORD!! "
 D ^DIR I $D(DIRUT) S XWBQUIT=1 Q
 S XWBAV=Y
 K DIR S DIR(0)="FAU^1:50",DIR("A")="Enter CONTEXT: ",DIR("B")="XWB BROKER EXAMPLE"
 D ^DIR I $D(DIRUT) S XWBQUIT=1 Q
 S XWBCONTX=Y
 I $G(XWBREPFL) D 
 .K DIR S DIR(0)="FAU^1:50",DIR("A")="Enter REPS: "
 .D ^DIR I $D(DIRUT) S XWBQUIT=1 Q
 .S XWBREPS=Y
 Q
 ;
OPEN(PORT,IP,AV) ;Opens connection to server.
 ;S IP="127.0.0.1",PORT="9800",AV="QQQQ11;11ZZZZ.." ;Local
 ;S IP="127.0.0.1",PORT="9800",AV="2287CTD;11ZZZZ.." ;BayPines Cache
 S XWBSTATE("M2M","OPEN")=$$CONNECT^XWBM2MC(PORT,IP,AV)
 Q
 ;
CLOSE ;Close the connection.
 S X=$$CLOSE^XWBM2MC()
 S XWBSTATE("M2M","OPEN")=0
 D CLEAN
 K X,XWBOPEN
 Q
 ;
CLEARP ;Clear the PARAMS array
 I '$G(XWBDBUG) K XWBPARMS
 D PRE^XWBM2MC
 Q
 ;
SETPARAM(INDEX,TYPE,VALUE) ;Set a Params entry
 S XWBPARMS("PARAMS",INDEX,"TYPE")=TYPE
 S XWBPARMS("PARAMS",INDEX,"VALUE")=VALUE
 Q
 ;
CLNTMP ;Kills the TMP("XWB*"
 K ^TMP("XWBM2M"),^TMP("XWBM2MVLC"),^TMP("XWBM2MRPC"),^TMP("XWBM2MRL")
 K ^TMP("XWBM2ME"),^TMP("XWBM2M"),^TMP("XWBM2ML")
 Q
 ;
CLEAN ;
 K REQ,XWBCONTX
 Q
 ;