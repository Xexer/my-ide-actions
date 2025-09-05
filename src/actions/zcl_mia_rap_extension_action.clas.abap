CLASS zcl_mia_rap_extension_action DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_action.
ENDCLASS.


CLASS zcl_mia_rap_extension_action IMPLEMENTATION.
  METHOD if_aia_action~run.
    DATA input TYPE zcl_mia_rap_extension_input=>input.

    TRY.
        context->get_input_config_content( )->get_as_structure( IMPORTING result = input ).
      CATCH cx_sd_invalid_data.
        RETURN.
    ENDTRY.

*    DATA(generator) = zcl_mia_core_factory=>create_object_generator( ).
*    DATA(generation_result) = generator->generate_objects_via_setting( setting ).
*
*    DATA(output) = zcl_mia_core_factory=>create_html_output( ).
*    DATA(html_output) = output->generate_html_output( generation_result ).

    DATA(action_result) = cl_aia_result_factory=>create_html_popup_result( ).
    action_result->set_content( |Test: { input-service_name }| ).

    result = action_result.
  ENDMETHOD.
ENDCLASS.
