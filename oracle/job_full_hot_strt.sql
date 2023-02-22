SELECT A.TYPE, A.STATUS, to_char(A.START_TIME, 'DD-MM-YYYY_HH24:MI:SS') start_dt, to_char(A.END_TIME, 'DD-MM-YYYY_HH24:MI:SS') end_dt, round((A.END_TIME-A.START_TIME)*24, 4) time, P.NAME policy,  s.name sch_name
  FROM netbackup.job a, NETBACKUP.SCHEDULER s, NETBACKUP.POLICY p
  WHERE A.SCHEDULER_ID = S.SCHEDULER_ID
    AND A.POLICY_ID = P.POLICY_ID
    AND regexp_like(upper(S.NAME), 'FULL')
    AND regexp_like(p.name, 'hot')
    AND regexp_like(p.name, 'strtdb')
--    AND upper(S.NAME) LIKE 'FULL'
    AND A.START_TIME >= to_date('19-06-2020', 'DD-MM-YYYY')
    AND A.END_TIME < to_date('23-06-2020', 'DD-MM-YYYY') 
    and A.STATUS = 0 
    and A.TYPE = 'backup'
  ORDER BY 3,4  