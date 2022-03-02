*&---------------------------------------------------------------------*
*& Include          ZAPI_TRACES_PLOAD_DOWN_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE ok_code.

    WHEN 'LOG_DOCU'.
      PERFORM show_log_document.

    WHEN 'ERROR_LOG'.
      SUBMIT /iwfnd/sutil_log
        AND RETURN.                                      "#EC CI_SUBMIT

    WHEN 'BACK' OR 'CANCEL'.
      LEAVE TO SCREEN 0.

    WHEN 'EXIT'.
      LEAVE PROGRAM.

  ENDCASE.

  CLEAR ok_code.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE ok_code.

    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
