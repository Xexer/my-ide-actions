CLASS zcl_mia_code_snippet_input DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_sd_action_input.

    CONSTANTS:
      BEGIN OF template_value,
        "! <p class="shorttext">Table: Change fields</p>
        table_rap_fields TYPE string VALUE 'table_rap_fields',
        "! <p class="shorttext">CDS: Change fields</p>
        cds_rap_fields   TYPE string VALUE 'cds_rap_fields',
      END OF template_value.

    "! $values { @link zcl_mia_code_snippet_input.data:template_value }
    "! $default { @link zcl_mia_code_snippet_input.data:template_value.table_rap_fields }
    TYPES template_name TYPE string.

    TYPES:
      "! <p class="shorttext">Choose a template</p>
      BEGIN OF input,
        type     TYPE c LENGTH 4,
        template TYPE template_name,
        entity   TYPE string,
      END OF input.
ENDCLASS.


CLASS zcl_mia_code_snippet_input IMPLEMENTATION.
  METHOD if_aia_sd_action_input~create_input_config.
    DATA input TYPE input.

    IF context IS BOUND.
      DATA(focused_object) = context->get_focused_resource( ).
      input-type = focused_object->get_type( ).
    ENDIF.

    DATA(configuration) = ui_information_factory->get_configuration_factory( )->create_for_data( input ).
    configuration->get_element( `TYPE` )->set_read_only( ).
    configuration->get_element( `TEMPLATE` )->set_sideeffect( after_update = abap_true ).
    configuration->get_element( `ENTITY` )->set_sideeffect( after_update = abap_true ).

    RETURN ui_information_factory->for_abap_type( abap_type     = input
                                                  configuration = configuration ).
  ENDMETHOD.


  METHOD if_aia_sd_action_input~get_side_effect_provider.
    RETURN cl_sd_sideeffect_provider=>create( determination   = NEW zcl_mia_code_snippet_side_eff( )
                                              feature_control = NEW zcl_mia_code_snippet_side_eff( ) ).
  ENDMETHOD.
ENDCLASS.
