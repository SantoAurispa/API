class ZCL_PAYLOAD_TRACE definition
  public
  final
  create public .

public section.

  types:
    tt_range_datum          TYPE RANGE OF sy-datum .
  types:
    tt_range_username       TYPE RANGE OF /iwfnd/su_tpload-username .
  types:
    tt_range_request_id     TYPE RANGE OF /iwfnd/su_tpload-request_id .
  types:
    BEGIN OF ty_payload.
  INCLUDE TYPE /iwfnd/sutil_payload_header.
  TYPES   erroricon  TYPE tv_image.
  TYPES   linecolor  TYPE c LENGTH 4.
  TYPES   request_kind_desc TYPE string.
  TYPES END OF ty_payload .
  types:
    tt_payload TYPE STANDARD TABLE OF ty_payload .
  types:
    tt_range_transaction_id TYPE RANGE OF /iwfnd/su_tpload-transaction_id .

  methods PAYLOAD_GET_HEADERS
    importing
      !IV_TODAY type XFELD optional
      !IT_DATUM type TT_RANGE_DATUM optional
      !IT_USERNAME type TT_RANGE_USERNAME optional
      !IT_REQUEST_ID type TT_RANGE_REQUEST_ID optional
      !IT_TRANSACTION_ID type TT_RANGE_TRANSACTION_ID optional
      !IV_REQUEST_URI type /IWFND/SU_TPLOAD-REQUEST_URI optional
    exporting
      !ET_PAYLOAD_HEADER type /IWFND/SUTIL_PAYLOAD_HEADER_T .
  methods PAYLOAD_GET
    importing
      !IV_TODAY type XFELD optional
      !IT_DATUM type TT_RANGE_DATUM optional
      !IT_USERNAME type TT_RANGE_USERNAME optional
      !IT_REQUEST_ID type TT_RANGE_REQUEST_ID optional
      !IT_TRANSACTION_ID type TT_RANGE_TRANSACTION_ID optional
      !IV_REQUEST_URI type /IWFND/SU_TPLOAD-REQUEST_URI optional
    exporting
      !ET_PAYLOAD type TT_PAYLOAD .
  methods DOWNLOAD_PAYLOAD
    importing
      !IS_PAYLOAD type /IWFND/SUTIL_PAYLOAD_RESULT
      !IV_DIALOG type BOOLEAN optional
      !IV_PATH type STRING optional .
protected section.
private section.

  types:
    BEGIN OF ty_payload_read,
      sapclient      TYPE /iwfnd/su_tpload-sapclient,
      opid           TYPE /iwfnd/su_tpload-opid,
      subno          TYPE /iwfnd/su_tpload-subno,
      username       TYPE /iwfnd/su_tpload-username,
      timestamp      TYPE /iwfnd/su_tpload-timestamp,
      localdate      TYPE /iwfnd/sutil_payload_header-local_date,
      localtime      TYPE /iwfnd/sutil_payload_header-local_time,
      errorstate     TYPE /iwfnd/su_tpload-errorstate,
      expirydate     TYPE /iwfnd/su_tpload-expiry_date,
      namespace      TYPE /iwfnd/su_tpload-namespace,
      servicename    TYPE /iwfnd/su_tpload-service_name,
      serviceversion TYPE /iwfnd/su_tpload-service_version,
      sourceclass    TYPE /iwfnd/su_tpload-source_program,
      sourcemethod   TYPE /iwfnd/su_tpload-source_include,
      transactionid  TYPE /iwfnd/su_tpload-transaction_id,
      requesturi     TYPE /iwfnd/su_tpload-request_uri,
      requestid      TYPE /iwfnd/su_tpload-request_id,
      httpmethod     TYPE /iwfnd/su_tpload-http_method,
      proctime       TYPE /iwfnd/su_tpload-proc_time,
      appltime       TYPE /iwfnd/su_tpload-appl_time,
      requsize       TYPE /iwfnd/su_tpload-requ_size,
      respsize       TYPE /iwfnd/su_tpload-resp_size,
      formattype     TYPE /iwfnd/su_tpload-format_type,
      nongwtime      TYPE /iwfnd/su_tpload-non_gw_time,
      requestkind    TYPE /iwfnd/su_tpload-request_kind,
    END OF ty_payload_read .
  types:
    tt_payload_read TYPE STANDARD TABLE OF ty_payload_read .

  constants:
    mc_color_one(4) value 'C020' ##NO_TEXT.
  constants:
    mc_color_two(4) value 'C000' ##NO_TEXT.
  constants:
    mc_color_app(4) value 'C100' ##NO_TEXT.
  constants:
    mc_color_sum(4) value 'C300' ##NO_TEXT.
  constants:
    mc_color_neg(4) value 'C600' ##NO_TEXT.
  constants MC_HTTP_BODY_BEG type STRING value '<HTTP_BODY>' ##NO_TEXT.
  constants MC_HTTP_BODY_END type STRING value '</HTTP_BODY>' ##NO_TEXT.
ENDCLASS.



CLASS ZCL_PAYLOAD_TRACE IMPLEMENTATION.


  METHOD download_payload.
    DATA: lv_type(40)      TYPE c,
          lv_subtype(40)   TYPE c,
          lv_do_unescape   TYPE abap_bool,
          lv_filename      TYPE string,
          lv_timestamp     TYPE string,
          lv_extension     TYPE string,
          lv_content_type  TYPE string,
          lv_time_char_22  TYPE c LENGTH 22,
          lv_time_char_14  TYPE c LENGTH 14,
          lv_http_body     TYPE xstring,
          lv_http_body_org TYPE xstring,
          ls_http_header   TYPE /iwfnd/sutil_property,
          lt_http_header   TYPE /iwfnd/sutil_property_t,
          lv_http_body_beg TYPE xstring,
          lv_http_body_end TYPE xstring,
          lv_fullpath      TYPE string.

    lv_http_body_beg     = /iwfnd/cl_sutil_xml_helper=>transform_to_xstring( mc_http_body_beg ).
    lv_http_body_end     = /iwfnd/cl_sutil_xml_helper=>transform_to_xstring( mc_http_body_end ).

* put timestamp into file name
    lv_time_char_22 = is_payload-timestamp.
    lv_time_char_14 = lv_time_char_22(14).
    lv_timestamp = lv_time_char_14.

* Get Header and Body
    /iwfnd/cl_sutil_xml_helper=>parse_http_data(
      EXPORTING
        iv_xmldata     = is_payload-trace_data
      IMPORTING
        et_http_header = lt_http_header
        ev_http_body   = lv_http_body
    ).
    READ TABLE lt_http_header INTO ls_http_header
      WITH KEY name = 'Content-Type'.                       "#EC NOTEXT
    IF sy-subrc <> 0.
      READ TABLE lt_http_header INTO ls_http_header
        WITH KEY name = 'content-type'.                     "#EC NOTEXT
    ENDIF.
    lv_content_type = ls_http_header-value.

* File extension xml
    IF lv_content_type IS INITIAL OR lv_content_type CS 'xml'. "#EC NOTEXT
      lv_extension = '.xml'.                                "#EC NOTEXT
      IF lv_http_body IS INITIAL.
        CONCATENATE lv_http_body_beg
                    lv_http_body_end
          INTO lv_http_body IN BYTE MODE.
      ENDIF.

    ELSEIF lv_content_type CS 'html'.                       "#EC NOTEXT
      lv_extension = '.html'.                               "#EC NOTEXT

    ELSEIF lv_content_type CS 'json' OR
           lv_content_type CS 'text' OR
           lv_content_type CS 'multipart'.                  "#EC NOTEXT
      lv_extension = '.txt'.                                "#EC NOTEXT
      IF lv_content_type CS 'json'.
        lv_http_body_org = lv_http_body.
        lv_do_unescape = abap_false.
        lv_http_body = /iwfnd/cl_sutil_xml_helper=>json_format(
                         iv_input       = lv_http_body_org
                         iv_do_unescape = lv_do_unescape
                       ).
      ENDIF.

    ELSE.
      SPLIT ls_http_header-value AT ';' INTO lv_type lv_subtype.
      IF lv_type IS NOT INITIAL.
        SPLIT lv_type AT '/' INTO lv_type lv_subtype.
      ENDIF.
      IF lv_subtype IS NOT INITIAL.
        CONCATENATE '.'
                    lv_subtype
          INTO lv_extension.
      ELSE.
        lv_extension = '.txt'.                              "#EC NOTEXT
      ENDIF.
    ENDIF.

    IF is_payload-call_type IS INITIAL.
      CONCATENATE 'SAPGW_Payload_'
                  lv_timestamp
                  lv_extension
        INTO lv_filename.
    ELSE.
      CONCATENATE 'SAPGW_Payload_'
                  lv_timestamp
                  '_'
                  is_payload-call_type
                  lv_extension
        INTO lv_filename.
    ENDIF.

    IF iv_path IS NOT INITIAL.
      CONCATENATE iv_path lv_filename INTO lv_fullpath SEPARATED BY '\'.
    ENDIF.

    CALL METHOD /iwfnd/cl_sutil_xml_helper=>xml_download
      EXPORTING
        iv_xdoc     = lv_http_body
        iv_dialog   = iv_dialog
        iv_path     = iv_path
        iv_fullpath = lv_fullpath
      CHANGING
        cv_filename = lv_filename.

  ENDMETHOD.


  METHOD payload_get.

    DATA:
      ls_header         TYPE /iwfnd/sutil_payload_header,
      lt_payload_header TYPE /iwfnd/sutil_payload_header_t,
      ls_payload        TYPE ty_payload.

    CALL METHOD me->payload_get_headers
      EXPORTING
        iv_today          = iv_today
        it_datum          = it_datum
        it_username       = it_username
        it_request_id     = it_request_id
        it_transaction_id = it_transaction_id
        iv_request_uri    = iv_request_uri
      IMPORTING
        et_payload_header = lt_payload_header.

    LOOP AT lt_payload_header INTO ls_header.

      CLEAR ls_payload.

      MOVE-CORRESPONDING ls_header TO ls_payload.
      ls_payload-linecolor = mc_color_two.

* Error Icon
      IF ls_payload-request_kind = /iwfnd/if_sutil_constants=>gcs_request_kind-client_local_v2 OR
        ls_payload-request_kind = /iwfnd/if_sutil_constants=>gcs_request_kind-client_local_v4.
        ls_payload-erroricon    = icon_led_yellow.
        ls_payload-erroricon+3  = '\Q'.
        ls_payload-erroricon+5  = TEXT-iok.
        ls_payload-erroricon+45 = '@'.
      ELSEIF ls_payload-errorstate IS INITIAL.
        ls_payload-erroricon    = icon_led_green.
        ls_payload-erroricon+3  = '\Q'.
        ls_payload-erroricon+5  = TEXT-iok.
        ls_payload-erroricon+45 = '@'.
      ELSE.
        ls_payload-erroricon    = icon_led_red.
        ls_payload-erroricon+3  = '\Q'.
        ls_payload-erroricon+5  = TEXT-ier.
        ls_payload-erroricon+45 = '@'.
      ENDIF.

      "Request kind description
      CASE ls_payload-request_kind.
        WHEN /iwfnd/if_sutil_constants=>gcs_request_kind-server_v2.
          ls_payload-request_kind_desc = 'Server OData v2'(058).
        WHEN /iwfnd/if_sutil_constants=>gcs_request_kind-server_v4.
          ls_payload-request_kind_desc = 'Server OData v4'(059).
        WHEN /iwfnd/if_sutil_constants=>gcs_request_kind-client_local_v2.
          ls_payload-request_kind_desc = 'Client local OData v2'(060).
        WHEN /iwfnd/if_sutil_constants=>gcs_request_kind-client_local_v4.
          ls_payload-request_kind_desc = 'Client local OData v4'(061).
        WHEN /iwfnd/if_sutil_constants=>gcs_request_kind-client_remote_v2.
          ls_payload-request_kind_desc = 'Client remote OData v2'(062).
        WHEN /iwfnd/if_sutil_constants=>gcs_request_kind-client_remote_v4.
          ls_payload-request_kind_desc = 'Client remote OData v4'(063).
        WHEN OTHERS.
          CLEAR ls_payload-request_kind_desc.
      ENDCASE.

      APPEND ls_payload TO et_payload.
    ENDLOOP.



  ENDMETHOD.


  METHOD payload_get_headers.
    DATA: lv_offset         TYPE i,
          lv_request_uri    TYPE string,
          ls_payload_read   TYPE ty_payload_read,
          lt_payload_read   TYPE tt_payload_read,
          ls_header         TYPE /iwfnd/sutil_payload_header,
          lt_payload_header TYPE /iwfnd/sutil_payload_header_t.


    IF iv_request_uri IS INITIAL.
      lv_request_uri = '%'.
    ELSE.
      CONCATENATE '%'
                  iv_request_uri
                  '%'
          INTO lv_request_uri.
    ENDIF.

    IF iv_today IS NOT INITIAL.

      SELECT sapclient       opid            subno           timestamp
            username         localdate       localtime       errorstate
            expirydate      namespace       servicename    serviceversion
            sourceclass     sourcemethod   transactionid  requesturi
            requestid       httpmethod     proctime       appltime
            requsize        respsize       formattype
            nongwtime      requestkind
       FROM ziploadheader
       INTO CORRESPONDING FIELDS OF TABLE lt_payload_read
       WHERE localdate      =    sy-datum
         AND username       IN   it_username
         AND requestid      IN   it_request_id
         AND transactionid  IN   it_transaction_id
         AND requesturi     LIKE lv_request_uri
       ORDER BY timestamp.

    ELSE.

      SELECT sapclient       opid            subno           timestamp
            username         localdate       localtime       errorstate
            expirydate      namespace       servicename    serviceversion
            sourceclass     sourcemethod   transactionid  requesturi
            requestid       httpmethod     proctime       appltime
            requsize        respsize       formattype
            nongwtime      requestkind
       FROM ziploadheader
       INTO CORRESPONDING FIELDS OF TABLE lt_payload_read
       WHERE localdate      IN   it_datum
         AND username       IN   it_username
         AND requestid      IN   it_request_id
         AND transactionid  IN   it_transaction_id
         AND requesturi     LIKE lv_request_uri
       ORDER BY timestamp.

    ENDIF.

    LOOP AT lt_payload_read INTO ls_payload_read.

      " Do the right work
      MOVE-CORRESPONDING ls_payload_read TO ls_header.

      ls_header-local_date = ls_payload_read-localdate.
      ls_header-local_time = ls_payload_read-localtime.
      ls_header-expiry_date = ls_payload_read-expirydate.
      ls_header-service_name = ls_payload_read-servicename.
      ls_header-service_version = ls_payload_read-serviceversion.
      ls_header-source_class = ls_payload_read-sourceclass.
      ls_header-source_method = ls_payload_read-sourcemethod.
      ls_header-transaction_id = ls_payload_read-transactionid.
      ls_header-request_uri = ls_payload_read-requesturi.
      ls_header-request_id = ls_payload_read-requestid.
      ls_header-http_method = ls_payload_read-httpmethod.
      ls_header-proc_time = ls_payload_read-proctime.
      ls_header-appl_time = ls_payload_read-appltime.
      ls_header-requ_size = ls_payload_read-requsize.
      ls_header-resp_size = ls_payload_read-respsize.
      ls_header-format_type = ls_payload_read-formattype.
      ls_header-non_gw_time = ls_payload_read-nongwtime.
      ls_header-request_kind = ls_payload_read-requestkind.

      IF ls_header-request_uri IS INITIAL.
        CONCATENATE ls_header-source_class
                    ls_header-source_method
          INTO ls_header-call_info SEPARATED BY ' - '.
      ELSE.
        SEARCH ls_header-request_uri FOR /iwfnd/cl_mgw_util_versions=>gcs_uri_prefix-sdata.
        IF sy-subrc = 0.
          lv_offset = sy-fdpos + strlen( /iwfnd/cl_mgw_util_versions=>gcs_uri_prefix-sdata ).
          ls_header-call_info = ls_header-request_uri+lv_offset.
        ELSE.
          SEARCH ls_header-request_uri FOR /iwfnd/cl_mgw_util_versions=>gcs_uri_prefix-odata_v4.
          IF sy-subrc = 0.
            lv_offset = sy-fdpos + strlen( /iwfnd/cl_mgw_util_versions=>gcs_uri_prefix-odata_v4 ).
            ls_header-call_info = ls_header-request_uri+lv_offset.
          ELSE.
            SEARCH ls_header-request_uri FOR /iwfnd/cl_mgw_util_versions=>gcs_uri_prefix-odata_v2.
            IF sy-subrc = 0.
              lv_offset = sy-fdpos + strlen( /iwfnd/cl_mgw_util_versions=>gcs_uri_prefix-odata_v2 ).
              ls_header-call_info = ls_header-request_uri+lv_offset.
            ELSE.
              ls_header-call_info = ls_header-request_uri.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      APPEND ls_header TO lt_payload_header.
    ENDLOOP.

    SORT lt_payload_header DESCENDING BY timestamp.

    et_payload_header = lt_payload_header.

  ENDMETHOD.
ENDCLASS.
