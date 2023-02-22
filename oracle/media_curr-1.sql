SELECT to_char(A.DATE_EXPIRATION, 'DD.MM.YYYY') date_expr, p_name, barcode, slot, kilobytes, mounts 
  FROM netbackup.media_tld0 a
  WHERE A.DATE_EXPIRATION < to_date('01-07-2020', 'DD-MM-YYYY')
--    AND A.DATE_EXPIRATION > current_date 
--  ORDER by A.DATE_EXPIRATION desc, p_name, barcode
ORDER by p_name, barcode