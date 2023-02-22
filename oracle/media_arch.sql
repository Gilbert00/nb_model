SELECT p_name, barcode, slot, kilobytes, mounts,  to_char(A.DATE_EXPIRATION, 'DD.MM.YYYY') date_expr
  FROM netbackup.media_tld0 a
  WHERE p_name IN ( 'Archive', 'Archive-ERP', 'ITC_Arch' )
  ORDER by p_name, barcode