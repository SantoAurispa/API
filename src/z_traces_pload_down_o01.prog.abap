*&---------------------------------------------------------------------*
*& Include          ZAPI_TRACES_PLOAD_DOWN_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'MAIN'.
  SET TITLEBAR 'MAIN'.

  IF mo_payload_area IS INITIAL.
    CREATE OBJECT mo_payload_area
      EXPORTING
        container_name = 'PAYLOAD_AREA'.

    PERFORM create_ms_payload_layout.

    CREATE OBJECT mo_payload_grid
      EXPORTING
        i_parent = mo_payload_area.

    CREATE OBJECT mo_gui_config.

    SET HANDLER mo_gui_config->handle_grid_double_click     FOR mo_payload_grid.
    SET HANDLER mo_gui_config->handle_hide_menu             FOR mo_payload_grid.
    SET HANDLER mo_gui_config->handle_toolbar               FOR mo_payload_grid.
    SET HANDLER mo_gui_config->handle_display_rows          FOR mo_payload_grid.
    SET HANDLER mo_gui_config->handle_get_context_menu      FOR mo_payload_grid.
    SET HANDLER mo_gui_config->handle_refresh_button        FOR mo_payload_grid.
    SET HANDLER mo_gui_config->handle_display_request_uri   FOR mo_payload_grid.
    SET HANDLER mo_gui_config->handle_download              FOR mo_payload_grid.

    PERFORM create_payload_fieldcat.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'REQUEST_URI'.
  SET TITLEBAR 'SHOW_REQUEST_URI'.
ENDMODULE.
