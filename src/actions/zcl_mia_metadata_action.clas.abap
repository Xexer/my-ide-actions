CLASS zcl_mia_metadata_action DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_action.
ENDCLASS.


CLASS zcl_mia_metadata_action IMPLEMENTATION.
  METHOD if_aia_action~run.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA input TYPE zcl_mia_metadata_input=>input.

    TRY.
        context->get_input_config_content( )->get_as_structure( IMPORTING result = input ).

      CATCH cx_sd_invalid_data.
        CLEAR input.
    ENDTRY.

    DATA(resource) = CAST if_adt_context_src_based_obj( context->get_focused_resource( ) ).
    DATA(position) = resource->get_position( ).

    DATA(mapped_fields) = ``.

    DATA(change_result) = cl_aia_result_factory=>create_source_change_result( ).
    change_result->add_code_replacement_delta( content            = mapped_fields
                                               selection_position = position ).
    result = change_result.
  ENDMETHOD.
ENDCLASS.
