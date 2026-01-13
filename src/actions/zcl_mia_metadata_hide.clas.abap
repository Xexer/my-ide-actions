CLASS zcl_mia_metadata_hide DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sd_action_model.
ENDCLASS.


CLASS zcl_mia_metadata_hide IMPLEMENTATION.
  METHOD if_sd_action_model~run.
    DATA input TYPE zcl_mia_metadata_input=>input.

    TRY.
        model->get_as_structure( IMPORTING result = input ).
        DATA(selected_lines) = path->get_as_table( ).
      CATCH cx_sd_invalid_data.
        CLEAR input.
    ENDTRY.

    LOOP AT selected_lines INTO DATA(line) WHERE row <> path->c_no_index.
      DATA(field) = REF #( input-fields[ line-row ] ).
      CLEAR: field->pos_fieldgroup, field->pos_identification, field->pos_lineitem, field->pos_selection,
             field->qualifier.
    ENDLOOP.

    changed_model = input.
  ENDMETHOD.
ENDCLASS.
