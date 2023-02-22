SELECT barcode, slot, mounts, p_name
  FROM netbackup.media_tld0
  WHERE p_name = 'Bad'
  ORDER by barcode