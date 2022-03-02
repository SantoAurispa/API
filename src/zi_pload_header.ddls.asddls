@ClientHandling.algorithm: #SESSION_VARIABLE
@AbapCatalog.sqlViewName: 'ZIPLOADHEADER'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Get payload header for trace'
@VDM.viewType: #BASIC
@Search.searchable: true

@ObjectModel.usageType.sizeCategory: #XL
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.dataClass: #MASTER
define view ZI_PLOAD_HEADER
  as select from /iwfnd/su_tpload
  association [0..1] to ZI_PLOAD_USER as _PloadUser on $projection.Username = _PloadUser.Username
{
  key sapclient              as Sapclient,
  key opid                   as Opid,
  key subno                  as Subno,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key username               as Username,
      timestamp              as Timestamp,
      @Semantics.businessDate.at: true
      tstmp_to_dats(timestamp,
                    abap_system_timezone( $session.client,'NULL' ),
                    $session.client,
                    'NULL' ) as LocalDate,
      tstmp_to_tims(timestamp,
                    abap_system_timezone( $session.client,'NULL' ),
                    $session.client,
                    'NULL' ) as LocalTime,
      errorstate             as Errorstate,
      expiry_date            as ExpiryDate,
      namespace              as Namespace,
      service_name           as ServiceName,
      service_version        as ServiceVersion,
      source_class           as SourceClass,
      source_method          as SourceMethod,
      transaction_id         as TransactionId,
      request_id             as RequestId,
      request_uri            as RequestUri,
      http_method            as HttpMethod,
      proc_time              as ProcTime,
      appl_time              as ApplTime,
      requ_size              as RequSize,
      resp_size              as RespSize,
      format_type            as FormatType,
      non_gw_time            as NonGwTime,
      request_kind           as RequestKind,

      //Association
      _PloadUser
}
where
  subno = 1
