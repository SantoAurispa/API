@AbapCatalog.sqlViewName: 'ZIPLOADUSER'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Get payload user for trace'
@Search.searchable: true

@ObjectModel.usageType.sizeCategory: #M
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.dataClass: #MASTER
define view ZI_PLOAD_USER
  as select distinct from /iwfnd/su_tpload
  association [0..*] to ZI_PLOAD_HEADER as _PloadHeader on $projection.Username = _PloadHeader.Username
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  key username as Username,
  
     //Association
      _PloadHeader
}
