SELECT barcode, slot, mounts, p_name
  FROM netbackup.media_tld0
  WHERE p_name = 'ZAPAS'
  ORDER by barcode