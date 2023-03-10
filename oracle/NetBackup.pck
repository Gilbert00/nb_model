create or replace package netbackup.NetBackup is

  -- Author  : KEMPER
  -- Created : 10.02.2010 16:53:14
  -- Purpose : 
  -- Version : 20230304
  
  -- Public type declarations
--  type <TypeName> is <Datatype>;
  
  -- Public constant declarations
--  <ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
--  <VariableName> <Datatype>;

  -- Public function and procedure declarations
--  function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;

--------
  function GetCurrentMasterID
             return number;
--------
  function SetCurrentMaster
            (pMasterName varchar2,
			 pMasterIP varchar2)
			return number;
			
--------
  function GetDateUpdate
            return date;
			
--------
  procedure SetDateUpdate(
             pDateUpdate date := current_date
            );
--------
  function GetPolicyID
            (pPolicyName varchar2)
            return number;

--------
  procedure SetRetention
              (pInd number, 
               pSecs number, 
               pKvo number, 
               pPeriod varchar2);

--------
  function SetHost
            (pHostType varchar2 := null, 
             pOS varchar2 := null, 
             pOSType  varchar2 := null, 
             pVersion  varchar2 := null, 
             pStatus  varchar2 := null, 
             pName  varchar2, 
             pIP varchar2 := null) 
             return number;

--------
  procedure SetRobot
            (pRobotNumber number,
             pRobotName varchar2,
             pRobotType varchar2,
             pHostName varchar2,
             pRobotPath varchar2);

--------
  function SetDrive
             (pName varchar2,
              pType varchar2,
              pRobotName varchar2 := null,
              pRDNumber number := null,
              pSerial varchar2 := null,
              pHostName varchar2 := null,
              pDrivePath varchar2 := null)
            return number;

--------
  procedure SetPath0
            (pDriveID number, 
             pHostID number, 
             pDrivePath varchar2,             
             pStatus    varchar2 := null,
             pDriveIndex number := null);

--------
  procedure SetPath
            (pDriveName varchar2, 
             pHostName varchar2, 
             pDrivePath varchar2,
             pStatus    varchar2 := null,
             pType      varchar2 := null,
             pDriveIndex number := null);
             
--------
  function SetVolumePool
            (pName  varchar2, 
             pDescr varchar2 := null) 
             return number;
             
--------
  function SetScratchPool
            (pName  varchar) 
             return number;

--------
  function SetCatalogPool
            (pName  varchar) 
             return number;
             
--------
  function SetVolumeGroup
            (pName  varchar2, 
             pMediaType varchar2 := null,
             pRobotNumber number := null) 
             return number;
--------
  procedure SetMedia
            (pMediaID varchar2, 
             pBarcode varchar2 := null, 
             pSlot number := null, 
             pMediaStatus varchar2 := null, 
             pMounts number := null, 
             pTimeassigned date := null, 
             pFirstMount date := null, 
             pLastMount date := null, 
             pCreated date := null, 
             pLastWritten date := null, 
             pLastRead date := null, 
             pDateExpiration date := null, 
             pKilobytes number := null, 
             pImages number := null, 
             pValidImages number := null, 
             pRetention number := null, 
             pVolumeGroupID number := null, 
             pVolumePoolName varchar2 := null, 
             pMediaServerName varchar2 := null,
             pRestores number := null 
            ); 
             
--------
  procedure SetMedia1
            (pMediaID varchar2, 
             pMediaStatus varchar2 := null, 
             pLastWritten date := null, 
             pLastRead date := null, 
             pDateExpiration date := null, 
             pKilobytes number := null, 
             pImages number := null, 
             pValidImages number := null, 
             pRetention number := null, 
             pMediaServerName varchar2 := null,
             pRestores number := null 
            );
--------
  procedure SaveMedia
            (pMediaID varchar2, 
             pBarcode varchar2 := null, 
             pSlot number := null, 
             pMounts number := null, 
             pTimeassigned date := null, 
             pFirstMount date := null, 
             pLastMount date := null, 
             pCreated date := null, 
             pDateExpiration date := null, 
             pVolumeGroupID number := null, 
             pVolumePoolName varchar2 := null
            );
--------
  function SetStorageUnit
            (pSUName  varchar2, 
             pISGroup number := null,
             pMediaServerName varchar2 := null,
             pMaxDrives number := null,
             pDensity varchar2  := null,
             pRobot number  := null,
             pFragSize number  := null,
             pMultiplex number  := null,
             pType varchar2 := null,
             pSubType varchar2 := null,
             pPath varchar2 := null,
             pConcJobs number := null,
             pHighWMark number := null,
             pLowWMark number := null,
             pDiskPool varchar2 := null,
             pIsSLP number := null,
             pSLPDupPriority number := null,
             pSLPVersion number := null,
             pSLPState varchar2 := null) 
             return number;

--------
  procedure SetStorageUnitInGroup
            (pGroupID number, 
             pMemberName varchar2); 

--------
  procedure DelStorageUnitGroup
            (pGroupID number); 
--------
  function SetSLP
            (pSLPName varchar2,
             pDupPriority number,
             pState varchar2,
             pVersion number)
             return number;
--------
  procedure SetSLPDetail
            (pSLPID number, 
             pOperIndex number, 
             pStorageName varchar2 := null, 
             pVolumePoolName varchar2 := null, 
             pRetentionType number := null, 
             pRetentionID number := null, 
             pAltReadName varchar2 := null, 
             pMultiplex number := null, 
             pRemoteImport number := null, 
             pSourceIndex number := null, 
             pDefDuplication number := null, 
             pOperName varchar2 := null, 
             pState varchar2 := null, 
             pWindowName varchar2 := null, 
             pWindowClose varchar2 := null
            ); 
--------
  procedure DelSLPDetail
            (pSLPID number); 
--------
  function SetPolicy
            (pPolicyName varchar2, 
             pType varchar2 := null,
             pActive number,
             pStarted date := null,
             pCompression number := null,
             pJobPriority number  := null,
             pEncryption number  := null,
             pKeyword varchar2 := null,
             pMaxJobs number := null,
             pStorageUnitName varchar2 := null,
             pVolumePoolName varchar2 := null,
             pAltClientName varchar2 := null,
             pBlockIncr number := null,
             pSnapshotBK number := null,
             pSnapshotMethod varchar2 := null,
             pOffshotBK number := null,
             pUseVM number := null) 
             return number;

--------
  procedure SetClient
            (pPolicyID number, 
             pClientName varchar2);

--------
  procedure DelClient
            (pPolicyID number); 

--------
  procedure SetSelection
            (pPolicyID number, 
             pLineID number,
             pLine varchar2); 

--------
  procedure DelSelection
            (pPolicyID number); 

--------
  function SetScheduler
            (pPolicyID number, 
             pSchedulerName varchar2,
             pBackupType varchar2 := null,
             pIsCalendar number := null,
             pFreqCount number  := null,
             pMediaMult number := null,
             pCopies number := null,
             pDuplPriority number := null) 
             return number;

--------
  procedure SetCopy
            (pSchedulerID number, 
             pNumb number,
             pRetention number  := null,
             pFail varchar2 := null,
             pStorageUnitName varchar2 := null,
             pVolumePoolName varchar2 := null);
              
--------
  procedure DelCopy
            (pSchedulerID number); 


--------
  procedure SetWindow
            (pSchedulerID number, 
             pDay number,
             pStartSecs number  := null,
             pDurationsecs number := null);

--------
  procedure DelWindow
            (pSchedulerID number); 
             
--------
  procedure SetJob
            (paramID number, 
             pType varchar2 := null,
             pState varchar2 := null,
             pStatus number := null,
             pStartTime date := null,
             pEndTime date := null,
             pActiveStart date := null,
             pActiveElapsed date := null,
             pAttempt number := null,
             pKilobytes number := null,
             pPID number := null,
             pKBsecs number := null,
             pFiles number := null,
             pOwner varchar2 := null,
             pCopy number := null,
             pParent number := null,
             pSessionID number := null,
             pMediaEject number := null,
             pMediaServerName varchar2 := null, 
             pClientName varchar2 := null,
             pPolicyName varchar2 := null,
             pSchedulerName varchar2 := null,
             pMasterName varchar2 := null,
             pVaultProfileName varchar2 := null); 
             
--------
  function GetJobState
            (pOuterID number)
            return varchar2; 

--------
  procedure SetJobDetail
            (pOuterID number, 
             pTry   number,
             pNLine number,
             pLineStr varchar2);

--------
  procedure DelJobDetail
            (pOuterID number); 
              


end NetBackup;
/
create or replace package body netbackup.NetBackup is

  -- Version : 20230310

  -- Private type declarations
--  type <TypeName> is <Datatype>;
  
  -- Private constant declarations
--  <ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
--  <VariableName> <Datatype>;
    gDateUpdate date;
	  gCurrentMasterID number := -1;

  -- Function and procedure implementations
/*  function <FunctionName>(<Parameter> <Datatype>) return <Datatype> is
    <LocalVariable> <Datatype>;
  begin
    <Statement>;
    return(<Result>);
  end;
*/

--------
  function GetCurrentMasterID
             return number
  is 
  begin
    return gCurrentMasterID;
  end GetCurrentMasterID;

--------
  function SetCurrentMaster
            (pMasterName varchar2,
			 pMasterIP varchar2)
			return number
  is
  begin
	gCurrentMasterID := SetHost( 
                         pName => pMasterName, 
                         pIP => pMasterIP, 
                         pHostType => 'master' );
	
	update host
	  set master_id = gCurrentMasterID
	  where host_id = gCurrentMasterID;
	  
	commit;  
	
	return gCurrentMasterID;
  end SetCurrentMaster; 

--------
  function GetDateUpdate
            return date
  is
  begin
    return gDateUpdate;
  end GetDateUpdate;  
  
--------
  procedure SetDateUpdate(
             pDateUpdate date := current_date
            )
  is
  begin
    gDateUpdate := pDateUpdate;
  end SetDateUpdate;                

--------
  function GetHostID
            (pHostName varchar2)
            return number
  is
    HostID integer;
  begin
    SELECT host_id
      INTO HostID
      FROM host
     WHERE name = pHostName;
     
    return HostID; 
  exception
  when NO_DATA_FOUND then   
    return null;
  end GetHostID;            

--------
  function SetHost
            (pHostType varchar2 := null, 
             pOS varchar2 := null, 
             pOSType  varchar2 := null, 
             pVersion  varchar2 := null, 
             pStatus  varchar2 := null, 
             pName  varchar2, 
             pIP varchar2 := null) 
             return number
  is
    HostID number;
  begin 
    update host
       set host_type = nvl(pHostType, host_type),
           os = nvl(pOS, os),
           os_type = nvl(pOSType, os_type),
           version = nvl(pVersion, version),
           status = nvl(pStatus, status),
           date_update = GetDateUpdate,
		   master_id = gCurrentMasterID,
          ip = nvl(pIP, ip)
     where name = pName
     returning host_id into HostID;

    if SQL%FOUND then
      commit;
      return HostID;
    end if;

    insert into host
      (host_type, os, os_type, version, status, name, ip, date_insert, date_update, master_id)
    values
      (pHostType, pOS, pOSType, pVersion, pStatus, pName, pIP, GetDateUpdate, GetDateUpdate, gCurrentMasterID)
    returning host_id into HostID;
    commit;
    return HostID;
  end  SetHost;           

--------
  function GetRobotID
            (pRobotName varchar2)
            return number
  is
    RobotID integer;
  begin
    SELECT robot_id
      INTO RobotID
      FROM robot
     WHERE robot_name = pRobotName
       AND master_id = gCurrentMasterID;
     
    return RobotID; 
  exception
  when NO_DATA_FOUND then   
    return null;
  end GetRobotID;            

--------
  function GetRobotID1
            (pRobotNumber number)
            return number
  is
    RobotID integer;
  begin
    SELECT robot_id
      INTO RobotID
      FROM robot
     WHERE robot_number = pRobotNumber
       AND master_id = gCurrentMasterID;
     
    return RobotID; 
  exception
  when NO_DATA_FOUND then   
    return null;
  end GetRobotID1;            

--------
  function GetVolumePoolID
            (pVolumePoolName varchar2)
            return number
  is
    VolumePoolID integer;
  begin
    SELECT volumepool_id
      INTO VolumePoolID
      FROM volumepool
     WHERE name = pVolumePoolName;
     
    return VolumePoolID; 
  exception
  when NO_DATA_FOUND then   
    return null;
  end GetVolumePoolID;            

--------
  function GetStorageUnitID
            (pStorageUnitName varchar2)
            return number
  is
    StorageUnitID integer;
  begin
    SELECT storageunit_id
      INTO StorageUnitID
      FROM storageunit
     WHERE name = pStorageUnitName;
     
    return StorageUnitID; 
  exception
  when NO_DATA_FOUND then   
    return null;
  end GetStorageUnitID;            

--------
  procedure SetRetention
              (pInd number, 
               pSecs number, 
               pKvo number, 
               pPeriod varchar2)
  is
  begin
    update retention
       set secs = pSecs,
           period = pPeriod,
           date_update = GetDateUpdate,
		   master_id = gCurrentMasterID,
           kvo = pKvo
     where ind = pInd;
      
    if SQL%FOUND then
      commit;
      return;
    end if;

    insert into retention
      (ind, secs, period, kvo, date_insert, date_update, master_id)
    values
      (pInd, pSecs, pPeriod, pKvo, GetDateUpdate, GetDateUpdate, gCurrentMasterID);

    commit;

  end SetRetention;               

--------
  procedure SetRobot
            (pRobotNumber number,
             pRobotName varchar2,
             pRobotType varchar2,
             pHostName varchar2,
             pRobotPath varchar2)
  is
    HostID integer;
  begin
     HostID := GetHostID(pHostName);
  
    update robot
       set robot_name = pRobotName,
           robot_type = pRobotType,
           robotic_path = pRobotPath,
            date_update = GetDateUpdate,
			master_id = gCurrentMasterID,
          host_id = HostID
     where robot_number = pRobotNumber;
 
    if SQL%FOUND then
      commit;
      return;
    end if;

    insert into robot
      (robot_number, robot_name, robot_type, robotic_path, host_id, date_insert, date_update, master_id)
    values
      (pRobotNumber, pRobotName, pRobotType, pRobotPath, HostID, GetDateUpdate, GetDateUpdate, gCurrentMasterID);
 
    commit;
    
  end SetRobot;           
             
--------
  function SetDrive
             (pName varchar2,
              pType varchar2,
              pRobotName varchar2 := null,
              pRDNumber number := null,
              pSerial varchar2 := null,
              pHostName varchar2 := null,
              pDrivePath varchar2 := null)
            return number
  is
    RobotID integer;
    HostID integer;
    DriveID integer;
  begin
    if pRobotName is not null then
      RobotID := GetRobotID(pRobotName);
    end if;

    update drive
       set type = pType,
           serial_number = nvl(pSerial, serial_number),
           date_update = GetDateUpdate,
           robot_id = nvl(RobotID, robot_id)
     where name = pName
    returning drive_id into DriveID;
      
    if SQL%NOTFOUND then
      insert into drive
        (name, type, serial_number, robot_id, date_insert, date_update)
      values
        (pName, pType, pSerial, RobotID, GetDateUpdate, GetDateUpdate)
      returning drive_id into DriveID;
    end if;
     
    commit;

    if (pDrivePath is not null) or (pRDNumber is not null) then
      HostID := GetHostID(pHostName);
      SetPath0(DriveID, HostID, pDrivePath, null, pRDNumber);
    end if;  

    return DriveID;
  
  end SetDrive;

--------
  procedure SetPath0
            (pDriveID number, 
             pHostID number, 
             pDrivePath varchar2,             
             pStatus    varchar2 := null,
             pDriveIndex number := null)
  is
  begin
    update path
       set drive_path = pDrivePath,
           status = nvl(pStatus, status),
           date_update = GetDateUpdate,
          drive_index = nvl(pDriveIndex, drive_index)
     where host_id = pHostID
       and drive_id = pDriveID;
    
    if SQL%FOUND then
      commit;
      return;
    end if;

    insert into path
      (drive_path, host_id, drive_id, status, drive_index, date_insert, date_update)
    values
      (pDrivePath, pHostID, pDriveID, pStatus, pDriveIndex, GetDateUpdate, GetDateUpdate);

    commit;
  end SetPath0;           

--------
  procedure SetPath
            (pDriveName varchar2, 
             pHostName varchar2, 
             pDrivePath varchar2,
             pStatus    varchar2 := null,
             pType      varchar2 := null,
             pDriveIndex number := null)
  is
    HostID integer;
    DriveID integer;
  begin
    HostID := GetHostID(pHostName);

    begin
    SELECT drive_id 
      INTO DriveID
      FROM drive
      WHERE name = pDriveName;

    exception
    when NO_DATA_FOUND then
      DriveID := SetDrive(pDriveName, pType);
    end;

    SetPath0
     (DriveID, 
      HostID, 
      pDrivePath,
      pStatus,
--      pType,
      pDriveIndex);
/*  
    update path
       set drive_path = pDrivePath,
           status = pStatus,
           drive_index = pDriveIndex
     where host_id = HostID
       and drive_id = DriveID;
    
    if SQL%FOUND then
      commit;
      return;
    end if;

    insert into path
      (drive_path, host_id, drive_id, status, drive_index)
    values
      (pDrivePath, HostID, DriveID, pStatus, pDriveIndex, GetDateUpdate, GetDateUpdate);

    commit;
*/
  end SetPath;           

--------
  function SetVolumePool
            (pName  varchar2, 
             pDescr varchar2 := null) 
             return number
  is
    VolumePoolID number;
  begin 
    update volumepool
       set 
           date_update = GetDateUpdate,
           description = pDescr,
		   master_id = gCurrentMasterID
     where name = pName
    returning volumepool_id into VolumePoolID;

    if SQL%FOUND then
      commit;
      return VolumePoolID;
    end if;

    insert into volumepool
      (description, name, date_insert, date_update, master_id)
    values
      (pDescr, pName, GetDateUpdate, GetDateUpdate, gCurrentMasterID)
    returning volumepool_id into VolumePoolID;

    commit;
    return VolumePoolID;
  end  SetVolumePool;           

--------
  function SetScratchPool
            (pName  varchar) 
             return number
  is
    VolumePoolID number;
  begin 
    update volumepool
       set 
           date_update = GetDateUpdate,
       is_scratch = 1
     where name = pName
    returning volumepool_id into VolumePoolID;
    commit;
    return VolumePoolID;
  end  SetScratchPool;           

--------
  function SetCatalogPool
            (pName  varchar) 
             return number
  is
    VolumePoolID number;
  begin 
    update volumepool
       set 
           date_update = GetDateUpdate,
       is_catalog = 1
     where name = pName
    returning volumepool_id into VolumePoolID;
    commit;
    return VolumePoolID;
  end  SetCatalogPool;           

--------
  function SetVolumeGroup
            (pName  varchar2, 
             pMediaType varchar2 := null,
             pRobotNumber number := null) 
             return number
  is
    VolumeGroupID number;
    RobotID number;
  begin 
    RobotID := GetRobotID1(pRobotNumber);  
  
    update volumegroup
       set media_type = nvl(pMediaType, media_type),
           date_update = GetDateUpdate,
           robot_id = nvl(RobotID, robot_id),
		   master_id = gCurrentMasterID
     where name = pName
    returning volumegroup_id into VolumeGroupID;

    if SQL%FOUND then
      commit;
      return VolumeGroupID;
    end if;

    insert into volumegroup
      (name, media_type, robot_id, date_insert, date_update, master_id)
    values
      (pName, pMediaType, pRobotNumber, GetDateUpdate, GetDateUpdate, gCurrentMasterID)
    returning volumegroup_id into VolumeGroupID;
    commit;
    return VolumeGroupID;
  end  SetVolumeGroup;           

--------
  procedure SetMedia
            (pMediaID varchar2, 
             pBarcode varchar2 := null, 
             pSlot number := null, 
             pMediaStatus varchar2 := null, 
             pMounts number := null, 
             pTimeassigned date := null, 
             pFirstMount date := null, 
             pLastMount date := null, 
             pCreated date := null, 
             pLastWritten date := null, 
             pLastRead date := null, 
             pDateExpiration date := null, 
             pKilobytes number := null, 
             pImages number := null, 
             pValidImages number := null, 
             pRetention number := null, 
             pVolumeGroupID number := null, 
             pVolumePoolName varchar2 := null, 
             pMediaServerName varchar2 := null,
             pRestores number := null 
            ) 
  is
    VolumePoolID integer;
    MediaServerID integer;
  begin 
    if pVolumePoolName is not null then
      VolumePoolID := GetVolumePoolID(pVolumePoolName);
    end if;

    if pMediaServerName is not null then
      MediaServerID := GetHostID(pMediaServerName);
    end if;

    update media
       set barcode = nvl(pBarcode, barcode),
           slot = nvl(pSlot, slot),
           media_status = nvl(pMediaStatus, media_status),
           mounts = nvl(pMounts, mounts),
           time_assigned = nvl(pTimeassigned, time_assigned),
           first_mount = nvl(pFirstMount, first_mount),
           last_mount = nvl(pLastMount, last_mount),
           created = nvl(pCreated, created),
           last_written = nvl(pLastWritten, last_written),
           last_read = nvl(pLastRead, last_read),
           date_expiration = nvl(pDateExpiration, date_expiration),
           kilobytes = nvl(pKilobytes, kilobytes),
           images = nvl(pImages, images),
           valid_images = nvl(pValidImages, valid_images),
           retention = nvl(pRetention, retention),
           volumegroup_id = nvl(pVolumeGroupID, volumegroup_id),
           volumepool_id = nvl(VolumePoolID, volumepool_id),
           media_server_id = nvl(MediaServerID, media_server_id),
           date_update = GetDateUpdate,
           restores = nvl(pRestores, restores)
     where media_id = pMediaID;

    if SQL%FOUND then
      commit;
      return;
    end if;
  
    insert into media
      (media_id, barcode, slot, media_status, mounts, time_assigned, first_mount, 
       last_mount, created, last_written, last_read, date_expiration, kilobytes, 
       images, valid_images, retention, volumegroup_id, volumepool_id, media_server_id,
       restores, date_insert, date_update)
    values
      (pMediaID, pBarcode, pSlot, pMediaStatus, pMounts, pTimeassigned, pFirstMount, 
       pLastMount, pCreated, pLastWritten, pLastRead, pDateExpiration, pKilobytes, 
       pImages, pValidImages, pRetention, pVolumeGroupID, VolumePoolID, MediaServerID,
       pRestores, GetDateUpdate, GetDateUpdate);
    commit;
  end  SetMedia;           

--------
  procedure SetMedia1
            (pMediaID varchar2, 
             pMediaStatus varchar2 := null, 
             pLastWritten date := null, 
             pLastRead date := null, 
             pDateExpiration date := null, 
             pKilobytes number := null, 
             pImages number := null, 
             pValidImages number := null, 
             pRetention number := null, 
             pMediaServerName varchar2 := null,
             pRestores number := null 
            ) 
  is
    MediaServerID integer;
  begin 
    if pMediaServerName is not null then
      MediaServerID := GetHostID(pMediaServerName);
    end if;

    update media
       set media_status = pMediaStatus,
           last_written = pLastWritten,
           last_read = pLastRead,
           date_expiration = pDateExpiration,
           kilobytes = pKilobytes,
           images = pImages,
           valid_images = pValidImages,
           retention = pRetention,
           media_server_id = MediaServerID,
           date_update = GetDateUpdate,
		   master_id = gCurrentMasterID,
           restores = pRestores
     where media_id = pMediaID;

    if SQL%FOUND then
      commit;
      return;
    end if;
  
    insert into media
      (media_id, media_status,
       last_written, last_read, date_expiration, kilobytes, 
       images, valid_images, retention, media_server_id,
       restores, date_insert, date_update, master_id)
    values
      (pMediaID, pMediaStatus,
       pLastWritten, pLastRead, pDateExpiration, pKilobytes, 
       pImages, pValidImages, pRetention, MediaServerID,
       pRestores, GetDateUpdate, GetDateUpdate, gCurrentMasterID);
    commit;
  end  SetMedia1;           

--------
  procedure SaveMedia
            (pMediaID varchar2, 
             pBarcode varchar2 := null, 
             pSlot number := null, 
             pMounts number := null, 
             pTimeassigned date := null, 
             pFirstMount date := null, 
             pLastMount date := null, 
             pCreated date := null, 
             pDateExpiration date := null, 
             pVolumeGroupID number := null, 
             pVolumePoolName varchar2 := null
            ) 
  is
    VolumePoolID integer;
  begin 
    if pVolumePoolName is not null then
      VolumePoolID := GetVolumePoolID(pVolumePoolName);
    end if;

    update media
       set barcode = pBarcode,
           slot = pSlot,
           mounts = pMounts,
           time_assigned = pTimeassigned,
           first_mount = pFirstMount,
           last_mount = pLastMount,
           created = pCreated,
           date_expiration = pDateExpiration,
           volumegroup_id = pVolumeGroupID,
           date_update = GetDateUpdate,
           volumepool_id = VolumePoolID
     where media_id = pMediaID;

    if SQL%FOUND then
      commit;
      return;
    end if;
  
    insert into media
      (media_id, barcode, slot, mounts, time_assigned, first_mount, 
       last_mount, created, date_expiration,  
       volumegroup_id, volumepool_id, date_insert, date_update
      )
    values
      (pMediaID, pBarcode, pSlot, pMounts, pTimeassigned, pFirstMount, 
       pLastMount, pCreated, pDateExpiration,  
       pVolumeGroupID, VolumePoolID, GetDateUpdate, GetDateUpdate
      );
    commit;
  end  SaveMedia;           

--------
  function SetStorageUnit
            (pSUName  varchar2, 
             pISGroup number := null,
             pMediaServerName varchar2 := null,
             pMaxDrives number := null,
             pDensity varchar2  := null,
             pRobot number  := null,
             pFragSize number  := null,
             pMultiplex number  := null,
             pType varchar2 := null,
             pSubType varchar2 := null,
             pPath varchar2 := null,
             pConcJobs number := null,
             pHighWMark number := null,
             pLowWMark number := null,
             pDiskPool varchar2 := null,
             pIsSLP number := null,
             pSLPDupPriority number := null,
             pSLPVersion number := null,
             pSLPState varchar2 := null) 
             return number
  is
    MediaServerNameID number;
    StorageUnitID number;
    RobotID number;
  begin 
    if pMediaServerName is not null then
      MediaServerNameID := GetHostID(pMediaServerName);
    end if;
    
    RobotID := GetRobotID1(pRobot);
      
    update storageunit
       set robot_id = nvl(RobotID, robot_id),
           density = nvl(pDensity, density),
           fragment_size = nvl(pFragSize, fragment_size),
           max_drives = nvl(pMaxDrives, max_drives),
           multiplexing = nvl(pMultiplex, multiplexing),
           is_group = pISGroup,
           media_server_id = nvl(MediaServerNameID, media_server_id),
           type = nvl(pType, type),
           subtype = nvl(pSubType, subtype),
           path = nvl(pPath, path),
           conc_jobs = nvl(pConcJobs, conc_jobs),
           high_wmark = nvl(pHighWMark, high_wmark),
           low_wmark = nvl(pLowWMark, low_wmark),
           disk_pool = nvl(pDiskPool, disk_pool),
           is_slp = nvl(pIsSLP, is_slp),
           slp_dup_priority = nvl(pSLPDupPriority, slp_dup_priority),
           slp_version = nvl(pSLPVersion, slp_version),
           date_update = GetDateUpdate,
		   master_id = gCurrentMasterID,
           slp_state = nvl(pSLPState, slp_state)
       where name = pSUName
    returning storageunit_id into StorageUnitID;

    if SQL%FOUND then
      commit;
      return StorageUnitID;
    end if;

    insert into storageunit
      (name, robot_id, density, fragment_size, max_drives, multiplexing, 
       is_group, media_server_id, type, subtype, path, conc_jobs,
       high_wmark, low_wmark, disk_pool, 
       is_slp, slp_dup_priority, slp_version, slp_state, date_insert, date_update, master_id)
    values
      (pSUName, RobotID, pDensity, pFragSize, pMaxDrives, pMultiplex, 
       pISGroup, MediaServerNameID, pType, pSubType, pPath, pConcJobs,
       pHighWMark, pLowWMark, pDiskPool, 
       pIsSLP, pSLPDupPriority, pSLPVersion, pSLPState, GetDateUpdate, GetDateUpdate, gCurrentMasterID)
    returning storageunit_id into StorageUnitID;

    commit;

    return StorageUnitID;

  end  SetStorageUnit;           

--------
  procedure SetStorageUnitInGroup
            (pGroupID number, 
             pMemberName varchar2) 
  is
    MemberID number;
  begin 
    begin
      SELECT storageunit_id
        INTO MemberID
        FROM storageunit
        WHERE name = pMemberName;

      exception
      when NO_DATA_FOUND then
        return;
    end;

    insert into storageunitingroup
      (storageunitgroup_id, storageunit_id, date_insert, date_update)
    values
      (pGroupID, MemberID, GetDateUpdate, GetDateUpdate);
      
    commit;

  exception
  when DUP_VAL_ON_INDEX then
    null;

  end  SetStorageUnitInGroup;           

--------
  procedure DelStorageUnitGroup
            (pGroupID number) 
  is
  begin 
    DELETE storageunitingroup
      WHERE storageunitgroup_id = pGroupID;
      
    commit;
  end  DelStorageUnitGroup;           

--------
  function SetSLP
            (pSLPName varchar2,
             pDupPriority number,
             pState varchar2,
             pVersion number)
             return number
is
begin
  return SetStorageUnit
          (pSUName => pSLPName,
           pIsSLP => 1,
           pSLPDupPriority => pDupPriority,
           pSLPVersion => pVersion,
           pSLPState => pState);         
end SetSLP;

--------
  procedure SetSLPDetail
            (pSLPID number, 
             pOperIndex number, 
             pStorageName varchar2 := null, 
             pVolumePoolName varchar2 := null, 
             pRetentionType number := null, 
             pRetentionID number := null, 
             pAltReadName varchar2 := null, 
             pMultiplex number := null, 
             pRemoteImport number := null, 
             pSourceIndex number := null, 
             pDefDuplication number := null, 
             pOperName varchar2 := null, 
             pState varchar2 := null, 
             pWindowName varchar2 := null, 
             pWindowClose varchar2 := null
            ) 
  is
    VolumePoolID integer;
    StorageID integer;
    AltReadID integer;
  begin 
    if pVolumePoolName is not null then
      VolumePoolID := GetVolumePoolID(pVolumePoolName);
    end if;

    if pStorageName is not null then
      StorageID := GetStorageUnitID(pStorageName);

    end if;

    if pAltReadName is not null then
      AltReadID := GetHostID(pAltReadName);
    end if;

    insert into slp_detail
      (slp_id, oper_index, storage_id, volumepool_id, retention_type,
       retention_id, alt_read_id, multiplex, remote_import, source_index,
       def_duplication, oper_name, state, window_name, window_close, date_insert, date_update)
    values
      (pSLPID, pOperIndex, StorageID, VolumePoolID, pRetentionType,
       pRetentionID, AltReadID, pMultiplex, pRemoteImport, pSourceIndex,
       pDefDuplication, pOperName, pState, pWindowName, pWindowClose, GetDateUpdate, GetDateUpdate);
    commit;
    
  exception
  when DUP_VAL_ON_INDEX then
    null;
  
  end  SetSLPDetail;           
--------
  procedure DelSLPDetail
            (pSLPID number) 
  is
  begin 
    DELETE slp_detail
      WHERE slp_id = pSLPID;
      
    commit;
  end  DelSLPDetail;           

--------
  function GetPolicyID
            (pPolicyName varchar2)
            return number
  is
    PolicyID integer;
  begin
    SELECT policy_id
      INTO PolicyID
      FROM policy
     WHERE name = pPolicyName;
     
    return PolicyID; 
  exception
  when NO_DATA_FOUND then   
    return null;
  end GetPolicyID;            

--------
  function GetSchedulerID
            (pPolicyID number,
             pSchedulerName varchar2)
             return number
  is
    SchedulerID integer;
  begin
    SELECT scheduler_id
      INTO SchedulerID
      FROM scheduler
     WHERE policy_id = pPolicyID
       AND name = pSchedulerName;
     
    return SchedulerID; 
  exception
  when NO_DATA_FOUND then   
    return null;
  end GetSchedulerID;            

--------
  function SetPolicy
            (pPolicyName varchar2, 
             pType varchar2 := null,
             pActive number,
             pStarted date := null,
             pCompression number := null,
             pJobPriority number  := null,
             pEncryption number  := null,
             pKeyword varchar2 := null,
             pMaxJobs number := null,
             pStorageUnitName varchar2 := null,
             pVolumePoolName varchar2 := null,
             pAltClientName varchar2 := null,
             pBlockIncr number := null,
             pSnapshotBK number := null,
             pSnapshotMethod varchar2 := null,
             pOffshotBK number := null,
             pUseVM number := null) 
             return number
  is
    VolumePoolID number;
    StorageUnitID number;
    PolicyID number;
    AltClientID number;
  begin 
    if pStorageUnitName is not null then
      StorageUnitID := GetStorageUnitID(pStorageUnitName);
      if StorageUnitID is null then
        StorageUnitID := SetStorageUnit(pStorageUnitName, 0);
      end if;
    end if;

    if pVolumePoolName is not null then
      VolumePoolID := GetVolumePoolID(pVolumePoolName);
    end if;

    if pAltClientName is not null then
      AltClientID := GetHostID(pAltClientName);
    end if;

    update policy
       set type = nvl(pType, type),
           job_priority = nvl(pJobPriority, job_priority),
           max_jobs = nvl(pMaxJobs, max_jobs),
           active = nvl(pActive, active),
           active_start = nvl(pStarted, active_start),
           compression = nvl(pCompression, compression),
           encryption = nvl(pEncryption, encryption),
           keyword = nvl(pKeyword, keyword),
           volumepool_id = nvl(VolumePoolID, volumepool_id),
           storageunit_id = nvl(StorageUnitID, storageunit_id),
           alt_client_id = nvl(AltClientID, alt_client_id),
           block_incr = nvl(pBlockIncr, block_incr),
           snapshot_bk = nvl(pSnapshotBK, snapshot_bk),
           snapshot_method = nvl(pSnapshotMethod, snapshot_method),
           offhost_bk = nvl(pOffshotBK, offhost_bk),
           date_update = GetDateUpdate,
		   master_id = gCurrentMasterID,
           use_vm = nvl(pUseVM, use_vm) 
     where name = pPolicyName
    returning policy_id into PolicyID;

    if SQL%FOUND then
      commit;
      return PolicyID;
    end if;

    insert into policy
      (name, type, job_priority, max_jobs, active, active_start, 
       compression, encryption, keyword, volumepool_id, storageunit_id,
       alt_client_id, block_incr, snapshot_bk, snapshot_method, offhost_bk,
       use_vm, date_insert, date_update, master_id)
    values
      (pPolicyName, pType, pJobPriority, pMaxJobs, pActive, pStarted, 
       pCompression, pEncryption, pKeyword, VolumePoolID, StorageUnitID,
       AltClientID, pBlockIncr, pSnapshotBK, pSnapshotMethod, pOffshotBK,
       pUseVM, GetDateUpdate, GetDateUpdate, gCurrentMasterID)
    returning policy_id into PolicyID;
      
    commit;
    return PolicyID;

  end  SetPolicy;           

--------
  procedure SetClient
            (pPolicyID number, 
             pClientName varchar2) 
  is
    ClientID number;
  begin 
    ClientID := GetHostID(pClientName);

    insert into client
      (host_id, policy_id, date_insert, date_update)
    values
      (ClientID, pPolicyID, GetDateUpdate, GetDateUpdate);
      
    commit;

  exception
  when DUP_VAL_ON_INDEX then
    null;

  end  SetClient;           

--------
  procedure DelClient
            (pPolicyID number) 
  is
  begin 
    DELETE client
      WHERE policy_id = pPolicyID;
      
    commit;
  end  DelClient;           

--------
  procedure SetSelection
            (pPolicyID number, 
             pLineID number,
             pLine varchar2) 
  is
  begin 
    insert into selection
      (list_item, list_id, policy_id, date_insert, date_update)
    values
      (pLine, pLineID, pPolicyID, GetDateUpdate, GetDateUpdate);
      
    commit;

  exception
  when DUP_VAL_ON_INDEX then
    null;

  end  SetSelection;           

--------
  procedure DelSelection
            (pPolicyID number) 
  is
  begin 
    DELETE selection
      WHERE policy_id = pPolicyID;
      
    commit;
  end  DelSelection;           

--------
  function SetScheduler
            (pPolicyID number, 
             pSchedulerName varchar2,
             pBackupType varchar2 := null,
             pIsCalendar number := null,
             pFreqCount number  := null,
             pMediaMult number := null,
             pCopies number := null,
             pDuplPriority number := null) 
             return number
  is
    SchedulerID number;
  begin 

    update scheduler
       set backup_type = nvl(pBackupType, backup_type),
           is_calendar = nvl(pIsCalendar, is_calendar),
           frequency_count = nvl(pFreqCount, frequency_count),
           media_mult = nvl(pMediaMult, media_mult),
           copies = nvl(pCopies, copies),
           date_update = GetDateUpdate,
           dupl_priority = nvl(pDuplPriority, dupl_priority)
     where policy_id = pPolicyID
       and name = pSchedulerName
    returning scheduler_id into SchedulerID;

    if SQL%FOUND then
      commit;
      return SchedulerID;
    end if;

    insert into scheduler
      (name, backup_type, is_calendar, frequency_count, 
       media_mult, copies, dupl_priority, policy_id, date_insert, date_update)
    values
      (pSchedulerName, pBackupType, pIsCalendar, pFreqCount, 
       pMediaMult, pCopies, pDuplPriority, pPolicyID, GetDateUpdate, GetDateUpdate)
    returning scheduler_id into SchedulerID;
      
    commit;
    return SchedulerID;

  end  SetScheduler;           

--------
  function GetPolicySTU
             (pSchedulerID number)
             return number
  is
    StorageUnitID number;
  begin
    SELECT p.storageunit_id
      INTO StorageUnitID
      FROM scheduler s, policy p  
      WHERE s.scheduler_id = pSchedulerID
        AND s.policy_id = p.policy_id;
  
    return StorageUnitID;
    
    exception
      when NO_DATA_FOUND then
      return null;
  
  end GetPolicySTU;             

--------
  function GetPolicyPool
             (pSchedulerID number)
             return number
  is
    VolumePoolID number;
  begin
    SELECT p.volumepool_id
      INTO VolumePoolID
      FROM scheduler s, policy p  
      WHERE s.scheduler_id = pSchedulerID
        AND s.policy_id = p.policy_id;
  
    return VolumePoolID;
    
    exception
      when NO_DATA_FOUND then
      return null;
  
  end GetPolicyPool;             

--------
  procedure SetCopy
            (pSchedulerID number, 
             pNumb number,
             pRetention number  := null,
             pFail varchar2 := null,
             pStorageUnitName varchar2 := null,
             pVolumePoolName varchar2 := null) 
  is
    VolumePoolID number;
    StorageUnitID number;
  begin 
    if pStorageUnitName is null then
      StorageUnitID := GetPolicySTU(pSchedulerID);
    else
      StorageUnitID := GetStorageUnitID(pStorageUnitName);
    end if;

    if pVolumePoolName is null then
      VolumePoolID := GetPolicyPool(pSchedulerID);
    else
      VolumePoolID := GetVolumePoolID(pVolumePoolName);
    end if;

    update copy
       set retention = nvl(pRetention, retention),
           copy_fails = nvl(pFail, copy_fails),
           volumepool_id = nvl(VolumePoolID, volumepool_id),
           date_update = GetDateUpdate,
           storageunit_id = nvl(StorageUnitID, storageunit_id)
     where numb = pNumb
       and scheduler_id = pSchedulerID;

    if SQL%FOUND then
      commit;
      return;
    end if;

    insert into copy
      (numb, retention, copy_fails, volumepool_id, storageunit_id, scheduler_id, date_insert, date_update)
    values
      (pNumb, pRetention, pFail, VolumePoolID, StorageUnitID, pSchedulerID, GetDateUpdate, GetDateUpdate);
      
    commit;
    return;

  end  SetCopy;           

--------
  procedure DelCopy
            (pSchedulerID number) 
  is
  begin 
    DELETE copy
      WHERE scheduler_id = pSchedulerID;
      
    commit;
  end  DelCopy;           

--------
  procedure SetWindow
            (pSchedulerID number, 
             pDay number,
             pStartSecs number  := null,
             pDurationsecs number := null) 
  is
  begin 

    update window
       set startsecs = nvl(pStartSecs, startsecs),
           date_update = GetDateUpdate,
           durationsecs = nvl(pDurationsecs, durationsecs)
     where scheduler_id = pSchedulerID
       and day = pDay;

    if SQL%FOUND then
      commit;
      return;
    end if;

    insert into window
      (day, startsecs, durationsecs, scheduler_id, date_insert, date_update)
    values
      (pDay, pStartSecs, pDurationsecs, pSchedulerID, GetDateUpdate, GetDateUpdate);
    
    commit;
    return;

  end  SetWindow;           

--------
  procedure DelWindow
            (pSchedulerID number) 
  is
  begin 
    DELETE window
      WHERE scheduler_id = pSchedulerID;
      
    commit;
  end  DelWindow;           


--------
  procedure SetJob
            (paramID number, 
             pType varchar2 := null,
             pState varchar2 := null,
             pStatus number := null,
             pStartTime date := null,
             pEndTime date := null,
             pActiveStart date := null,
             pActiveElapsed date := null,
             pAttempt number := null,
             pKilobytes number := null,
             pPID number := null,
             pKBsecs number := null,
             pFiles number := null,
             pOwner varchar2 := null,
             pCopy number := null,
             pParent number := null,
             pSessionID number := null,
             pMediaEject number := null,
             pMediaServerName varchar2 := null, 
             pClientName varchar2 := null,
             pPolicyName varchar2 := null,
             pSchedulerName varchar2 := null,
             pMasterName varchar2 := null,
             pVaultProfileName varchar2 := null) 
  is
    MediaServerID number; 
    ClientID number;
    PolicyID number;
    SchedulerID number;
    MasterID number;
    VaultProfileID number;
--    sql_found boolean;
--    sql_rowcount number;
  begin 

    if pMediaServerName is not null then
      MediaServerID := GetHostID(pMediaServerName);
    end if;

    if pClientName is not null then
      ClientID := GetHostID(pClientName);
    end if;

    if pMasterName is not null then
      MasterID := GetHostID(pMasterName);
    end if;

    if pPolicyName is not null then
      PolicyID := GetPolicyID(pPolicyName);
    end if;

    if pSchedulerName is not null then
      SchedulerID := GetSchedulerID(PolicyID, pSchedulerName);
    end if;

--TO_DO GetVaultProfileID

    update job
       set type = nvl(pType, type),
           state = nvl(pState, state),
           status = nvl(pStatus, status),
           start_time = nvl(pStartTime, start_time),
           end_time = nvl(pEndTime, end_time),
           active_start = nvl(pActiveStart, active_start),
           active_elapsed = nvl(pActiveElapsed, active_elapsed),
           attempt = nvl(pAttempt, attempt),
           kilobytes = nvl(pKilobytes, kilobytes),
           kbsec = nvl(pKBsecs, kbsec),
           files = nvl(pFiles, files),
           owner = nvl(pOwner, owner),
           copy = nvl(pCopy, copy),
           parent = nvl(pParent, parent),
           session_id = nvl(pSessionID, session_id),
           media_eject = nvl(pMediaEject, media_eject),
           media_server_id = nvl(MediaServerID, media_server_id),
           client_id = nvl(ClientID, client_id),
           policy_id = nvl(PolicyID, policy_id),
           scheduler_id = nvl(SchedulerID, scheduler_id),
           master_id = nvl(MasterID, master_id),
           vaultprofile_id = nvl(VaultProfileID, vaultprofile_id),
           date_update = GetDateUpdate,
           pid = nvl(pPID, pid)
     where outer_id = paramID;

--    sql_found := SQL%FOUND;
--    sql_rowcount := SQL%ROWCOUNT;

    if SQL%FOUND then
      commit;
      return;
    end if;

    insert into job
      (outer_id, type, state, status, start_time, end_time, active_start, active_elapsed, 
       attempt, kilobytes, kbsec, files, owner, copy, parent, session_id, 
       media_eject, media_server_id, client_id, policy_id, scheduler_id, master_id, 
       vaultprofile_id, pid, date_insert, date_update)
    values
      (paramID, pType, pState, pStatus, pStartTime, pEndTime, pActiveStart, pActiveElapsed, 
       pAttempt, pKilobytes, pKBsecs, pFiles, pOwner, pCopy, pParent, pSessionID, 
       pMediaEject, MediaServerID, ClientID, PolicyID, SchedulerID, MasterID, 
       VaultProfileID, pPID, GetDateUpdate, GetDateUpdate);
  
    commit;
    return;

  end  SetJob;           

--------
  function GetJobID
            (pMasterID number,
             pOuterID number)
            return number 
  is                                                         
    JobID integer;                                                                                                                                   
  begin
    SELECT a.job_id
      INTO JobID
      FROM job a
      where a.outer_id = pOuterID
        and a.master_id = pMasterID;
  
    return JobID;
       
  exception
    when NO_DATA_FOUND then
    return 0;
 
  end GetJobID;
  
--------
  function GetJobState
            (pOuterID number)
            return varchar2 
  is
    JobState varchar2(64);
    NJobdetail integer;
    JobID integer;
  begin
    SELECT a.state || ' ' || to_char(a.status)
      INTO JobState
      FROM job a
      where a.outer_id = pOuterID
        and a.master_id = gCurrentMasterID;
        
  JobID := GetJobID(gCurrentMasterID, pOuterID);     
  
    SELECT nvl(Count(*), 0)
      INTO NJobdetail
      FROM jobdetail
      where job_id = JobID;
      
  
    return ltrim(to_char(NJobdetail)) || ' ' || JobState;
       
  exception
    when NO_DATA_FOUND then
    return '0 ';
 
  end GetJobState;

--------
  procedure SetJobDetail
            (pOuterID number, 
             pTry   number,
             pNLine number,
             pLineStr varchar2) 
  is
    JobID integer;
  begin 
    JobID := GetJobID(gCurrentMasterID, pOuterID);
  
    insert into jobdetail
      (job_id, try, nline, linestr, date_insert, date_update)
    values
      (JobID, pTry, pNLine, pLineStr, GetDateUpdate, GetDateUpdate);
      
    commit;

  exception
  when DUP_VAL_ON_INDEX then
    null;

  end  SetJobDetail;           

--------
  procedure DelJobDetail
            (pOuterID number) 
  is
    JobID integer;
  begin 
    JobID := GetJobID(gCurrentMasterID, pOuterID);  
  
    DELETE jobdetail
      WHERE job_id = JobID;
      
    commit;
  end  DelJobDetail;           

--------
begin
  -- Initialization
--  <Statement>;
  null;
end NetBackup;
/
