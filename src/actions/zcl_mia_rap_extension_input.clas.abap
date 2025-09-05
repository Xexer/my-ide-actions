CLASS zcl_mia_rap_extension_input DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_sd_action_input.

    CONSTANTS:
      BEGIN OF extension_scenario,
        "! <p class="shorttext">Add new field</p>
        field TYPE string VALUE `add_field`,
      END OF extension_scenario.

    "! $values { @link zcl_mia_rap_extension_input.data:extension_scenario }
    "! $default { @link zcl_mia_rap_extension_input.data:extension_scenario.field }
    TYPES scenario TYPE string.

    TYPES:
      "! <p class="shorttext">Choose a template</p>
      BEGIN OF input,
        "! <p class="shorttext">Name of the Service</p>
        service_name TYPE string,
        "! <p class="shorttext">Extension scenario</p>
        scenario     TYPE scenario,
        "! <p class="shorttext">Entity</p>
        entity       TYPE string,
        "! <p class="shorttext">New field</p>
        new_field    TYPE string,
      END OF input.
ENDCLASS.


CLASS zcl_mia_rap_extension_input IMPLEMENTATION.
  METHOD if_aia_sd_action_input~create_input_config.
    DATA input TYPE input.

    IF context IS BOUND.
      DATA(focused_object) = context->get_focused_resource( ).
      input-service_name = focused_object->get_name( ).
    ENDIF.

    DATA(configuration) = ui_information_factory->get_configuration_factory( )->create_for_data( input ).

    configuration->get_element( `service_name` )->set_read_only( ).
    configuration->get_element( 'entity' )->set_values( if_sd_config_element=>values_kind-domain_specific_named_items ).

    RETURN ui_information_factory->for_abap_type( abap_type     = input
                                                  configuration = configuration ).
  ENDMETHOD.


  METHOD if_aia_sd_action_input~get_value_help_provider.
    result = cl_sd_value_help_provider=>create( NEW zcl_mia_rap_extension_value( ) ).
  ENDMETHOD.
ENDCLASS.
