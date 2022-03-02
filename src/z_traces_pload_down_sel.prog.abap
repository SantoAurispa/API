*&---------------------------------------------------------------------*
*& Include          ZAPI_TRACES_PLOAD_DOWN_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

PARAMETERS: r_today RADIOBUTTON GROUP rad DEFAULT 'X' USER-COMMAND flag,
            r_datum RADIOBUTTON GROUP rad.
SELECT-OPTIONS: s_datum FOR sy-datum MODIF ID dat,
                s_user FOR gv_username,
                s_reqid FOR gv_request_id,
                s_traid FOR gv_transaction_id.
PARAMETERS:     p_requri TYPE /iwfnd/su_tpload-request_uri.
SELECTION-SCREEN: END OF BLOCK b1.

AT SELECTION-SCREEN OUTPUT.

  PERFORM hide_show_parameters.

START-OF-SELECTION.

  PERFORM get_data.
