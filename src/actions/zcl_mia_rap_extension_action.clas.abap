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

    DATA(analyzer) = zcl_mia_core_factory=>create_rap_analyzer(
        object_name = input-service_name
        object_type = zif_mia_rap_analyzer=>start_object-service_binding ).
    DATA(rap_object) = analyzer->get_rap_object( ).

    DATA(extension) = zcl_mia_core_factory=>create_extension_steps( rap_object ).

    CASE input-scenario.
      WHEN zcl_mia_rap_extension_input=>extension_scenario-field.
        DATA(converted_output) = extension->generate_steps_for_new_field( VALUE #( entity = input-entity
                                                                                   name   = input-new_field ) ).
    ENDCASE.

    DATA(html_content) = zcl_mia_core_factory=>create_html_output( )->generate_generic_output( REF #( converted_output ) ).

    DATA(html_output) = cl_aia_result_factory=>create_html_popup_result( ).
    html_output->set_content( html_content ).

    result = html_output.
  ENDMETHOD.
ENDCLASS.
