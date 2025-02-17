CLASS zcl_mia_newclass_action DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_action.

ENDCLASS.


CLASS zcl_mia_newclass_action IMPLEMENTATION.
  METHOD if_aia_action~run.
    DATA popup_data TYPE zcl_mia_newclass_input=>input.

    TRY.
        context->get_input_config_content( )->get_as_structure( IMPORTING result = popup_data ).

      CATCH cx_sd_invalid_data.
        DATA(error_result) = cl_aia_result_factory=>create_text_popup_result( ).
        error_result->set_content( CONV #( TEXT-008 ) ).
        result = error_result.
        RETURN.
    ENDTRY.

    DATA(generator) = zcl_mia_core_factory=>create_object_generator( ).
    DATA(generation_result) = generator->generate_objects_via_setting( CORRESPONDING #( popup_data ) ).

    DATA(output) = zcl_mia_core_factory=>create_html_output( ).
    DATA(html_output) = output->generate_html_output( generation_result ).

    DATA(action_result) = cl_aia_result_factory=>create_html_popup_result( ).
    action_result->set_content( html_output ).

    result = action_result.
  ENDMETHOD.
ENDCLASS.
