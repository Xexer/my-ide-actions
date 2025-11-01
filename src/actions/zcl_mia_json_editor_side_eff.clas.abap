CLASS zcl_mia_json_editor_side_eff DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sd_determination.
ENDCLASS.


CLASS zcl_mia_json_editor_side_eff IMPLEMENTATION.
  METHOD if_sd_determination~run.
    DATA input  TYPE zcl_mia_json_editor_input=>input.
    DATA backup TYPE zcl_mia_json_editor_input=>input.

    IF determination_kind <> if_sd_determination=>kind-after_update.
      RETURN.
    ENDIF.

    model->get_as_structure( IMPORTING result = input ).
    backup = input.

    TRY.
        DATA(json_editor) = zcl_mia_core_factory=>create_json_editor( ).
        input-json_string = json_editor->format_json_string( input ).
        input-refresh     = zcl_mia_json_editor_input=>refresh_text.

      CATCH cx_root.
        input = backup.
    ENDTRY.

    result = input.
  ENDMETHOD.
ENDCLASS.
