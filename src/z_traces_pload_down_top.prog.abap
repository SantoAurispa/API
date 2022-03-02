*&---------------------------------------------------------------------*
*& Include          ZAPI_TRACES_PLOAD_DOWN_TOP
*&---------------------------------------------------------------------*
*TABLES /iwfnd/su_tpload.

TYPES BEGIN OF ty_payload.
INCLUDE TYPE /iwfnd/sutil_payload_header.
TYPES   erroricon  TYPE tv_image.
TYPES   linecolor  TYPE c LENGTH 4.
TYPES   request_kind_desc TYPE string.
TYPES END OF ty_payload.

TYPES:
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
  END OF ty_payload_read.
TYPES:
  tt_payload_read TYPE STANDARD TABLE OF ty_payload_read.

TYPES:
      tt_range_timestampl TYPE RANGE OF timestampl.

DATA: gt_payload      TYPE TABLE OF ty_payload,
      gt_except_qinfo TYPE lvc_t_qinf.

DATA: gv_username       TYPE /iwfnd/su_tpload-username,
      gv_request_id     TYPE /iwfnd/su_tpload-request_id,
      gv_transaction_id TYPE /iwfnd/su_tpload-transaction_id.

*CLASS lcl_config DEFINITION DEFERRED.

*CLASS cl_gui_cfw DEFINITION LOAD.

*----------------------------------------------------------------------*
*       CLASS lcl_config DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_config DEFINITION.

  PUBLIC SECTION.

    METHODS handle_hide_menu
                FOR EVENT context_menu_request OF cl_gui_alv_grid
      IMPORTING e_object.

    METHODS handle_grid_double_click
                FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row.

    METHODS handle_toolbar
                FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object.

    METHODS handle_display_rows
                FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

    METHODS handle_refresh_button
                FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

    METHODS handle_display_request_uri
                FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

    METHODS handle_get_context_menu
                FOR EVENT context_menu_request OF cl_gui_alv_grid
      IMPORTING e_object.

    METHODS handle_download
                FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.
ENDCLASS.                    "lcl_config DEFINITION

DATA: ok_code         TYPE sy-ucomm,
      ms_stable       TYPE lvc_s_stbl,
      mt_hidden_code  TYPE ui_functions,
      mo_gui_area     TYPE REF TO cl_gui_custom_container,
      mo_gui_config   TYPE REF TO lcl_config,
      mt_except_qinfo TYPE lvc_t_qinf.

DATA: ms_payload_layout  TYPE lvc_s_layo,
      ms_variant_payload TYPE disvariant,
      mt_payload_fcat    TYPE lvc_t_fcat,
      mo_payload_grid    TYPE REF TO cl_gui_alv_grid,
      mo_payload_area    TYPE REF TO cl_gui_custom_container,
      mv_request_uri     TYPE string.

CONSTANTS: gc_color_one(4) VALUE 'C020',                    "#EC NEEDED
           gc_color_two(4) VALUE 'C000',                    "#EC NEEDED
           gc_color_app(4) VALUE 'C100',                    "#EC NEEDED
           gc_color_sum(4) VALUE 'C300',                    "#EC NEEDED
           gc_color_neg(4) VALUE 'C600'.                    "#EC NEEDED





*---------------------------------------------------------------------*
*       CLASS LCL_CONFIG IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_config IMPLEMENTATION.

  METHOD handle_hide_menu.

    PERFORM hide_toolbar.

    CALL METHOD e_object->hide_functions
      EXPORTING
        fcodes = mt_hidden_code.

  ENDMETHOD.                    "handle_hide_menu


  METHOD handle_grid_double_click.

    DATA: ls_payload TYPE ty_payload.

* Payload Trace
    IF e_row-index IS NOT INITIAL.
      READ TABLE gt_payload INDEX e_row-index INTO ls_payload.
      SUBMIT /iwfnd/sutil_trace_pload WITH inp_opid = ls_payload-opid
        AND RETURN.                                      "#EC CI_SUBMIT
      PERFORM display_payload_overview.
    ENDIF.

  ENDMETHOD.                    "handle_grid_double_click


  METHOD handle_toolbar.

    DATA: ls_toolbar TYPE stb_button.

    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.

* Refresh
    CLEAR ls_toolbar.
    MOVE 'REFRESH'                      TO ls_toolbar-function.
    MOVE icon_refresh                   TO ls_toolbar-icon.
    MOVE 'Refresh'(011)                 TO ls_toolbar-quickinfo.
    APPEND ls_toolbar                   TO e_object->mt_toolbar.

* Display
    CLEAR ls_toolbar.
    MOVE 'DISPLAY'                    TO ls_toolbar-function.
    MOVE icon_display                 TO ls_toolbar-icon.
    MOVE 'Display selected entries'(017) TO ls_toolbar-quickinfo.
    APPEND ls_toolbar                 TO e_object->mt_toolbar.


* Request URI
    CLEAR ls_toolbar.
    MOVE 'REQUEST_URI'                TO ls_toolbar-function.
    MOVE icon_display                 TO ls_toolbar-icon.
    MOVE 'Request URI'(018)           TO ls_toolbar-text.
    MOVE 'Request URI'(018)           TO ls_toolbar-quickinfo.
    APPEND ls_toolbar                 TO e_object->mt_toolbar.

* Download
    CLEAR ls_toolbar.
    MOVE 'DOWNLOAD'                     TO ls_toolbar-function.
    MOVE icon_xml_doc                   TO ls_toolbar-icon.
    MOVE 'Download payload'(001)        TO ls_toolbar-quickinfo.
    MOVE 'Download'(002)                TO ls_toolbar-text.
    APPEND ls_toolbar                   TO e_object->mt_toolbar.



  ENDMETHOD.                    "handle_toolbar


  METHOD handle_display_rows.

    DATA: lv_error   TYPE xsdboolean,
          ls_row     TYPE lvc_s_roid,
          lt_row     TYPE lvc_t_roid,
          ls_payload TYPE ty_payload,
          lt_opid    TYPE /iwfnd/sutil_uuidc_t.

    IF e_ucomm = 'DISPLAY'.

      PERFORM grid_get_selected_rows USING mo_payload_grid lt_row.
      IF lt_row IS INITIAL. EXIT. ENDIF.
      LOOP AT lt_row INTO ls_row.
        READ TABLE gt_payload INDEX ls_row-row_id INTO ls_payload.
        IF sy-subrc = 0.
          APPEND ls_payload-opid TO lt_opid.
        ENDIF.
      ENDLOOP.
      SUBMIT /iwfnd/sutil_trace_pload WITH opids = lt_opid
        AND RETURN.                                      "#EC CI_SUBMIT
      PERFORM display_payload_overview.

    ENDIF.

  ENDMETHOD.                    "handle_display_rows


  METHOD handle_refresh_button.

    IF e_ucomm = 'REFRESH'.

      PERFORM display_payload_overview.

    ENDIF.

  ENDMETHOD.                    "handle_refresh_button


  METHOD handle_display_request_uri.

    DATA: ls_row     TYPE lvc_s_roid,
          lt_row     TYPE lvc_t_roid,
          ls_payload TYPE ty_payload.

    IF e_ucomm = 'REQUEST_URI'.


      PERFORM grid_get_selected_rows USING mo_payload_grid lt_row.
      READ TABLE lt_row INTO ls_row INDEX 1.
      IF sy-subrc <> 0. EXIT. ENDIF.
      READ TABLE gt_payload INTO ls_payload INDEX ls_row-row_id.
      mv_request_uri = ls_payload-request_uri.
      CALL SCREEN 200 STARTING AT 10 5 ENDING AT 145 6.
      CLEAR ok_code.

    ENDIF.

  ENDMETHOD.                    "handle_display_request_uri

  METHOD handle_get_context_menu.

    DATA: row_no TYPE i.

    CALL METHOD mo_payload_grid->get_current_cell
      IMPORTING
        e_row = row_no.


    IF row_no <> 0.
      CALL METHOD e_object->load_gui_status
        EXPORTING
          program = 'ZAPI_TRACES_PLOAD_DOWN'
          status  = 'DETAILS_MENU'
          menu    = e_object.
    ENDIF.

  ENDMETHOD.

  METHOD handle_download.


    DATA: ls_payload TYPE ty_payload,
          ls_row     TYPE lvc_s_roid,
          lt_row     TYPE lvc_t_roid,
          lt_opid    TYPE /iwfnd/sutil_uuidc_t,
          ls_result  TYPE /iwfnd/sutil_payload_result,
          lt_result  TYPE /iwfnd/sutil_payload_result_t,
          replaycode TYPE TABLE OF sy-ucomm,
          lv_path    TYPE string.


    IF e_ucomm = 'DOWNLOAD'.

      PERFORM grid_get_selected_rows USING mo_payload_grid lt_row.

      IF lt_row[] IS INITIAL.
        MESSAGE text-e02 TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.

      CALL METHOD cl_gui_frontend_services=>directory_browse
        EXPORTING
          initial_folder  = lv_path
        CHANGING
          selected_folder = lv_path
        EXCEPTIONS
          cntl_error      = 1
          error_no_gui    = 2
          OTHERS          = 3.

      CHECK sy-subrc EQ 0 AND lv_path IS NOT INITIAL.

      PERFORM download_payload USING lt_row lv_path.


    ENDIF.

  ENDMETHOD.

ENDCLASS.                    "lcl_config IMPLEMENTATION
