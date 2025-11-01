CLASS zcl_mia_json_editor_action DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_action.
ENDCLASS.


CLASS zcl_mia_json_editor_action IMPLEMENTATION.
  METHOD if_aia_action~run.
    DATA input TYPE zcl_mia_json_editor_input=>input.

    TRY.
        context->get_input_config_content( )->get_as_structure( IMPORTING result = input ).
      CATCH cx_sd_invalid_data.
        RETURN.
    ENDTRY.

    DATA(json_editor) = zcl_mia_core_factory=>create_json_editor( ).
    DATA(new_code) = json_editor->convert_json_to_code( input ).

    DATA(change_result) = cl_aia_result_factory=>create_source_change_result( ).
    DATA(resource) = CAST if_adt_context_src_based_obj( context->get_focused_resource( ) ).
    DATA(position) = resource->get_position( ).
    change_result->add_code_replacement_delta( content            = new_code
                                               selection_position = position ).
    result = change_result.
  ENDMETHOD.
ENDCLASS.
