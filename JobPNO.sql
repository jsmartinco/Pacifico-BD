
BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'PNO'
      ,job_type        => 'PLSQL_BLOCK'
      ,start_date      => TO_TIMESTAMP_TZ('12/01/2021 1:00:00.000 AM -05:00','mm/dd/yyyy hh12:mi:ss.ff AM tzr')
      ,repeat_interval => 'FREQ=MONTHLY'
      ,end_date        => TO_TIMESTAMP_TZ('1/30/2040 1:00:00.000 AM -05:00','mm/dd/yyyy hh12:mi:ss.ff AM tzr')
      ,auto_drop       => TRUE
      ,job_action      => '
                            BEGIN
								conceptospnoresidencial;
                                conceptospnovip;
                            END;
                          '
      ,comments        => 'Se crearn posibles PNO de acuerdo a condiciones..'
    );
END;