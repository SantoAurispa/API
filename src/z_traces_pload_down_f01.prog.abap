*&---------------------------------------------------------------------*
*& Include          ZAPI_TRACES_PLOAD_DOWN_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form HIDE_SHOW_PARAMETERS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM hide_show_parameters .

  CASE 'X'.
    WHEN r_today.
      LOOP AT SCREEN.
        IF screen-group1 = 'DAT'.
          screen-active = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN r_datum.
      LOOP AT SCREEN.
        IF screen-group1 = 'DAT'.
          screen-active = '1'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  DATA: ls_except_qinfo TYPE lvc_s_qinf,
        lv_today        TYPE xfeld,
        lv_requri TYPE /iwfnd/su_tpload-request_uri..

  FREE: gt_except_qinfo, gt_payload.

  IF r_today IS NOT INITIAL.
    lv_today = 'X'.
  ENDIF.

  lv_requri = p_requri.
  REPLACE ALL OCCURRENCES OF '*' IN lv_requri WITH space.
  CONDENSE lv_requri.

  DATA(lo_payload) = NEW zcl_payload_trace( ).


  CALL METHOD lo_payload->payload_get
    EXPORTING
      iv_today          = lv_today
      it_datum          = s_datum[]
      it_username       = s_user[]
      it_request_id     = s_reqid[]
      it_transaction_id = s_traid[]
      iv_request_uri    = lv_requri
    IMPORTING
      et_payload        = gt_payload.

  ls_except_qinfo-type = cl_salv_tooltip=>c_type_color.
  ls_except_qinfo-value = gc_color_two+1.
  ls_except_qinfo-text = 'Trace Header'(099).
  APPEND ls_except_qinfo TO gt_except_qinfo.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  create_ms_payload_layout.
*&---------------------------------------------------------------------*
FORM create_ms_payload_layout.

  DATA: lv_index    TYPE i,
        ls_gui_fcat TYPE lvc_s_fcat.

  CLEAR: mt_payload_fcat.
  ms_payload_layout-sel_mode   = 'A'.
  ms_payload_layout-info_fname = 'LINECOLOR'.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'ERRORICON'.
  ls_gui_fcat-coltext   = 'Status'(036).
  ls_gui_fcat-outputlen = 4.
  ls_gui_fcat-icon      = 'X'.
  APPEND ls_gui_fcat TO mt_payload_fcat.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'REQUEST_KIND_DESC'.
  ls_gui_fcat-coltext   = 'Request Kind'(057).
  ls_gui_fcat-outputlen = 20.
  ls_gui_fcat-dd_outlen = 40.
  APPEND ls_gui_fcat TO mt_payload_fcat.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'CALL_INFO'.
  ls_gui_fcat-coltext   = 'Service Call Info'(031).
  ls_gui_fcat-outputlen = 50.
  ls_gui_fcat-dd_outlen = 100.
  APPEND ls_gui_fcat TO mt_payload_fcat.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'HTTP_METHOD'.
  ls_gui_fcat-coltext   = 'Method'(040).
  ls_gui_fcat-scrtext_l = 'HTTP Method'(041).
  ls_gui_fcat-outputlen = 6.
  APPEND ls_gui_fcat TO mt_payload_fcat.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'PROC_TIME'.
  ls_gui_fcat-coltext   = 'Proc. Time'(042).
  ls_gui_fcat-scrtext_l = 'Processing Time in msec'(043).
  ls_gui_fcat-outputlen = 9.
  APPEND ls_gui_fcat TO mt_payload_fcat.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'APPL_TIME'.
  ls_gui_fcat-coltext   = 'Appl. Time'(044).
  ls_gui_fcat-scrtext_l = 'Application Time in msec'(045).
  ls_gui_fcat-outputlen = 9.
  APPEND ls_gui_fcat TO mt_payload_fcat.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'NON_GW_TIME'.
  ls_gui_fcat-coltext   = 'Non-GW Time'(055).
  ls_gui_fcat-scrtext_l = 'Non-GW Time in msec'(056).
  ls_gui_fcat-outputlen = 9.
  APPEND ls_gui_fcat TO mt_payload_fcat.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'REQU_SIZE'.
  ls_gui_fcat-coltext   = 'Req. Size'(046).
  ls_gui_fcat-scrtext_l = 'Request Size in Bytes'(047).
  ls_gui_fcat-outputlen = 8.
  APPEND ls_gui_fcat TO mt_payload_fcat.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'RESP_SIZE'.
  ls_gui_fcat-coltext   = 'Resp. Size'(048).
  ls_gui_fcat-scrtext_l = 'Response Size in Bytes'(049).
  ls_gui_fcat-outputlen = 9.
  APPEND ls_gui_fcat TO mt_payload_fcat.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'FORMAT_TYPE'.
  ls_gui_fcat-coltext   = 'Format'(053).
  ls_gui_fcat-scrtext_l = 'Response Format'(054).
  ls_gui_fcat-outputlen = 6.
  APPEND ls_gui_fcat TO mt_payload_fcat.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'USERNAME'.
  ls_gui_fcat-coltext   = 'Username'(030).
  ls_gui_fcat-outputlen = 10.
  APPEND ls_gui_fcat TO mt_payload_fcat.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'LOCAL_DATE'.
  ls_gui_fcat-coltext   = 'Date'(033).
  ls_gui_fcat-outputlen = 10.
  APPEND ls_gui_fcat TO mt_payload_fcat.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'LOCAL_TIME'.
  ls_gui_fcat-coltext   = 'Time'(034).
  ls_gui_fcat-outputlen = 8.
  APPEND ls_gui_fcat TO mt_payload_fcat.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'EXPIRY_DATE'.
  ls_gui_fcat-coltext   = 'Expiry Date'(035).
  ls_gui_fcat-outputlen = 10.
  APPEND ls_gui_fcat TO mt_payload_fcat.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'OPID'.
  ls_gui_fcat-coltext   = 'Operation ID'(037).
  ls_gui_fcat-outputlen = 32.
  ls_gui_fcat-lowercase = 'X'.
  ls_gui_fcat-no_out    = 'X'.
  APPEND ls_gui_fcat TO mt_payload_fcat.

  lv_index = lv_index + 1.
  CLEAR ls_gui_fcat.
  ls_gui_fcat-col_pos   = lv_index.
  ls_gui_fcat-fieldname = 'TRANSACTION_ID'.
  ls_gui_fcat-coltext   = 'Transaction ID'(039).
  ls_gui_fcat-outputlen = 32.
  ls_gui_fcat-lowercase = 'X'.
  ls_gui_fcat-no_out    = 'X'.
  APPEND ls_gui_fcat TO mt_payload_fcat.

ENDFORM.                    " create_ms_payload_layout
*&---------------------------------------------------------------------*
*&      Form  create_payload_fieldcat
*&---------------------------------------------------------------------*
FORM create_payload_fieldcat.

*  IF mv_select_utilid IS NOT INITIAL.
*    PERFORM get_payload_data.
*  ENDIF.

  MOVE sy-repid TO ms_variant_payload-report.

  CALL METHOD mo_payload_grid->set_table_for_first_display
    EXPORTING
      is_layout            = ms_payload_layout
      it_toolbar_excluding = mt_hidden_code
      i_save               = 'A'
      is_variant           = ms_variant_payload
      it_except_qinfo      = gt_except_qinfo
    CHANGING
      it_outtab            = gt_payload
      it_fieldcatalog      = mt_payload_fcat[].

  CALL METHOD mo_payload_grid->set_toolbar_interactive.

  CALL METHOD cl_gui_control=>set_focus
    EXPORTING
      control = mo_payload_grid.

ENDFORM.                    " create_payload_fieldcat
*&---------------------------------------------------------------------*
*& Form HIDE_TOOLBAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM hide_toolbar .
  CLEAR mt_hidden_code.

  APPEND cl_gui_alv_grid=>mc_fc_col_optimize      TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_help              TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_col_invisible     TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_find              TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy          TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_delete_filter     TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_unfix_columns     TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_subtot            TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_sum               TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_info              TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_print             TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_views             TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_graph             TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row      TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row    TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_loc_append_row    TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row    TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_loc_move_row      TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy          TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_loc_cut           TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste         TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste_new_row TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_loc_undo          TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_refresh           TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_check             TO mt_hidden_code.
  APPEND cl_gui_alv_grid=>mc_fc_auf               TO mt_hidden_code.

  APPEND cl_gui_alv_grid=>mc_mb_sum               TO mt_hidden_code.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_PAYLOAD_OVERVIEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_payload_overview .

  PERFORM get_data.

  CALL METHOD mo_payload_grid->refresh_table_display( is_stable = ms_stable ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GRID_GET_SELECTED_ROWS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> MO_PAYLOAD_GRID
*&      --> LT_ROW
*&---------------------------------------------------------------------*
FORM grid_get_selected_rows USING pr_grid  TYPE REF TO cl_gui_alv_grid
                                  pt_row   TYPE lvc_t_roid.

  DATA: ls_row  TYPE lvc_s_roid,
        lt_row  TYPE lvc_t_roid,
        ls_cell TYPE lvc_s_ceno,
        lt_cell TYPE lvc_t_ceno.

  CALL METHOD pr_grid->get_selected_rows
    IMPORTING
      et_row_no = lt_row.
  pt_row[] = lt_row[].

  IF pt_row[] IS INITIAL.
    CALL METHOD pr_grid->get_selected_cells_id
      IMPORTING
        et_cells = lt_cell.
    READ TABLE lt_cell INTO ls_cell INDEX 1.
    IF sy-subrc <> 0.
      MESSAGE i208(00) WITH 'Mark at least one entry'(009).
      EXIT.
    ENDIF.
    ls_row-row_id = ls_cell-row_id.
    APPEND ls_row TO pt_row.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*       FORM show_log_document
*---------------------------------------------------------------------*
FORM show_log_document.

  CONSTANTS: co_msgid_sutil    TYPE symsgid VALUE '/IWFND/COS_SUTIL',
             co_msgno_log_info TYPE symsgno VALUE '001'.

  DATA: lv_object TYPE dokhl-object,
        lt_line   TYPE TABLE OF tline.

  CALL FUNCTION 'DOCU_OBJECT_NAME_CONCATENATE'
    EXPORTING
      docu_id  = 'NA'
      element  = co_msgid_sutil
      addition = co_msgno_log_info
    IMPORTING
      object   = lv_object
    EXCEPTIONS
      OTHERS   = 1.

  IF sy-subrc = 0.
    CALL FUNCTION 'HELP_OBJECT_SHOW'
      EXPORTING
        dokclass = 'NA'
        dokname  = lv_object
      TABLES
        links    = lt_line.
  ENDIF.

ENDFORM.                    " show_log_document
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_PAYLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW
*&      --> LV_PATH
*&---------------------------------------------------------------------*
FORM download_payload  USING    pt_row   TYPE lvc_t_roid
                                pv_path.

  DATA: lo_sutil_moni TYPE REF TO /iwfnd/cl_sutil_moni,
        ls_row        TYPE lvc_s_roid,
        ls_payload    TYPE ty_payload,
        lt_opids      TYPE /iwfnd/sutil_uuidc_t,
        lv_opids      TYPE sysuuid_c,
        lt_result     TYPE /iwfnd/sutil_payload_result_t,
        ls_result     TYPE /iwfnd/sutil_payload_result.

  lo_sutil_moni   = /iwfnd/cl_sutil_moni=>get_instance( ).

  LOOP AT pt_row INTO ls_row.

    CLEAR ls_payload.
    READ TABLE gt_payload INTO ls_payload INDEX ls_row-row_id.

    CLEAR: lv_opids.
    FREE: lt_opids.

    lv_opids = ls_payload-opid.
    APPEND lv_opids TO lt_opids.

* Get Payload Traces
    lt_result = lo_sutil_moni->payload_get_result(
                  it_opid           = lt_opids
                ).

    LOOP AT lt_result INTO ls_result.

      PERFORM download USING ls_result pv_path.

      CLEAR: ls_result.
    ENDLOOP.

    CLEAR: ls_row.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_RESULT
*&---------------------------------------------------------------------*
FORM download  USING ps_result TYPE /iwfnd/sutil_payload_result
                     pv_path.

  DATA(lo_payload_download) = NEW zcl_payload_trace( ).

  CALL METHOD lo_payload_download->download_payload
    EXPORTING
      is_payload = ps_result
*     iv_dialog  =
      iv_path    = pv_path.

ENDFORM.
