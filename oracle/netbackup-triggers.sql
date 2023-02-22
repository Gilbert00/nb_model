DROP TRIGGER NETBACKUP.DRIVE_BI;

CREATE OR REPLACE TRIGGER NETBACKUP.Drive_BI
  BEFORE INSERT
  ON NETBACKUP.DRIVE
  for each row
BEGIN
:new.Drive_Id := netbackupid_seq.nextval;
END;
/


DROP TRIGGER NETBACKUP.HOST_BI;

CREATE OR REPLACE TRIGGER NETBACKUP.Host_BI
  BEFORE INSERT
  ON NETBACKUP.HOST
  for each row
BEGIN
:new.Host_Id := netbackupid_seq.nextval;
END;
/


DROP TRIGGER NETBACKUP.IMAGE_BI;

CREATE OR REPLACE TRIGGER NETBACKUP.IMAGE_BI
BEFORE INSERT
ON NETBACKUP.IMAGE
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
DECLARE
BEGIN
:new.Image_ID := netbackupid_seq.nextval;
END IMAGE_BI;
/


DROP TRIGGER NETBACKUP.POLICY_BI;

CREATE OR REPLACE TRIGGER NETBACKUP.Policy_BI
  BEFORE INSERT
  ON NETBACKUP.POLICY
  for each row
BEGIN
:new.Policy_ID := netbackupid_seq.nextval;
END;
/


DROP TRIGGER NETBACKUP.SCHEDULER_BI;

CREATE OR REPLACE TRIGGER NETBACKUP.Scheduler_BI
  BEFORE INSERT
  ON NETBACKUP.SCHEDULER
  for each row
BEGIN
:new.Scheduler_ID := netbackupid_seq.nextval;
END;
/


DROP TRIGGER NETBACKUP.STORAGEUNIT_BI;

CREATE OR REPLACE TRIGGER NETBACKUP.StorageUnit_BI
  BEFORE INSERT
  ON NETBACKUP.STORAGEUNIT
  for each row
BEGIN
:new.StorageUnit_ID := netbackupid_seq.nextval;
END;
/


DROP TRIGGER NETBACKUP.VAULTMGMT_BI;

CREATE OR REPLACE TRIGGER NETBACKUP.VaultMgmt_BI
  BEFORE INSERT
  ON NETBACKUP.VAULTMGMT
  for each row
BEGIN
:new.VaultMgmt_ID := netbackupid_seq.nextval;
END;
/


DROP TRIGGER NETBACKUP.VAULTPROFILE_BI;

CREATE OR REPLACE TRIGGER NETBACKUP.VaultProfile_BI
  BEFORE INSERT
  ON NETBACKUP.VAULTPROFILE
  for each row
BEGIN
:new.VaultProfile_ID := netbackupid_seq.nextval;
END;
/


DROP TRIGGER NETBACKUP.VAULTREPORT_BI;

CREATE OR REPLACE TRIGGER NETBACKUP.VaultReport_BI
  BEFORE INSERT
  ON NETBACKUP.VAULTREPORT
  for each row
BEGIN
:new.VaultReport_ID := netbackupid_seq.nextval;
END;
/


DROP TRIGGER NETBACKUP.VAULT_BI;

CREATE OR REPLACE TRIGGER NETBACKUP.Vault_BI
  BEFORE INSERT
  ON NETBACKUP.VAULT
  for each row
BEGIN
:new.Vault_ID := netbackupid_seq.nextval;
END;
/


DROP TRIGGER NETBACKUP.VAULT_RETENMAP_BI;

CREATE OR REPLACE TRIGGER NETBACKUP.Vault_RetenMap_BI
  BEFORE INSERT
  ON NETBACKUP.VAULT_RETENMAP
  for each row
BEGIN
:new.VaultReten_ID := netbackupid_seq.nextval;
END;
/


DROP TRIGGER NETBACKUP.VOLUMEGROUP_BI;

CREATE OR REPLACE TRIGGER NETBACKUP.VolumeGroup_BI
  BEFORE INSERT
  ON NETBACKUP.VOLUMEGROUP
  for each row
BEGIN
:new.VolumeGroup_ID := netbackupid_seq.nextval;
END;
/


DROP TRIGGER NETBACKUP.VOLUMEPOOL_BI;

CREATE OR REPLACE TRIGGER NETBACKUP.VolumePool_BI
  BEFORE INSERT
  ON NETBACKUP.VOLUMEPOOL
  for each row
BEGIN
:new.VolumePool_ID := netbackupid_seq.nextval;
END;
/