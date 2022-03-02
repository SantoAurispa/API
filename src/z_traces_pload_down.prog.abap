*&---------------------------------------------------------------------*
*& Report ZAPI_TRACES_PLOAD_DOWN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_traces_pload_down.

INCLUDE Z_TRACES_PLOAD_DOWN_TOP.
*INCLUDE zapi_traces_pload_down_top.
INCLUDE Z_TRACES_PLOAD_DOWN_SEL.
*INCLUDE zapi_traces_pload_down_sel.
INCLUDE Z_TRACES_PLOAD_DOWN_F01.
*INCLUDE zapi_traces_pload_down_f01.
INCLUDE Z_TRACES_PLOAD_DOWN_O01.
*INCLUDE zapi_traces_pload_down_o01.
INCLUDE Z_TRACES_PLOAD_DOWN_I01.
*INCLUDE zapi_traces_pload_down_i01.

START-OF-SELECTION.

  PERFORM get_data.

  IF gt_payload[] IS NOT INITIAL.
    CALL SCREEN 100.
  ELSE.
    MESSAGE TEXT-e01 TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
