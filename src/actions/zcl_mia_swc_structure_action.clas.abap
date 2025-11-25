CLASS zcl_mia_swc_structure_action DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_action.
ENDCLASS.


CLASS zcl_mia_swc_structure_action IMPLEMENTATION.
  METHOD if_aia_action~run.
    DATA input TYPE zcl_mia_swc_structure_input=>input.

    TRY.
        context->get_input_config_content( )->get_as_structure( IMPORTING result = input ).
      CATCH cx_sd_invalid_data.
    ENDTRY.

    DATA(setting) = CORRESPONDING zif_mia_object_generator=>package_setting( input-objects ).
    setting-package   = input-package.
    setting-transport = input-transport.

    DATA(generator) = zcl_mia_core_factory=>create_object_generator( ).
    DATA(generation_result) = generator->generate_package_structure( setting ).

    DATA(output) = zcl_mia_core_factory=>create_html_output( ).
    DATA(html_output) = output->generate_generic_output( REF #( generation_result ) ).

    DATA(action_result) = cl_aia_result_factory=>create_html_popup_result( ).
    action_result->set_content( html_output ).

    result = action_result.
  ENDMETHOD.
ENDCLASS.
