SELECT to_char(A.DATE_EXPIRATION, 'DD.MM.YYYY') date_expr, p_name, barcode, slot, kilobytes, mounts 
  FROM netbackup.media_tld0 a
  WHERE A.DATE_EXPIRATION >= to_date('04-09-2020', 'DD-MM-YYYY')
  --ORDER by p_name, barcode
  ORDER by DATE_EXPIRATION desc, p_name, barcode