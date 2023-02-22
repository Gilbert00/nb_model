DROP VIEW NETBACKUP.MEDIA_TLD0;

/* Formatted on 26.01.2021 11:54:19 (QP5 v5.287) */
CREATE OR REPLACE FORCE VIEW NETBACKUP.MEDIA_TLD0
(
   BARCODE,
   SLOT,
   MEDIA_STATUS,
   MOUNTS,
   LAST_WRITTEN,
   DATE_EXPIRATION,
   KILOBYTES,
   VALID_IMAGES,
   RETENTION,
   P_NAME,
   H_NAME,
   ROBOT_NUMBER
)
AS
   SELECT a.barcode,
          A.SLOT,
          A.MEDIA_STATUS,
          A.MOUNTS,
          A.LAST_WRITTEN,
          A.DATE_EXPIRATION,
          A.KILOBYTES,
          A.VALID_IMAGES,
          A.RETENTION,
          P.NAME p_name,
          H.NAME h_name,
          G.ROBOT_NUMBER
     FROM MEDIA a,
          VOLUMEPOOL p,
          HOST h,
          VOLUMEGROUP g
    WHERE     a.volumepool_id = p.volumepool_id
          AND A.MEDIA_SERVER_ID = H.HOST_ID(+)
          AND A.VOLUMEGROUP_ID = G.VOLUMEGROUP_ID
          AND G.ROBOT_NUMBER = 0;
