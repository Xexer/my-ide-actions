CLASS zcl_mia_consumption_input DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_sd_action_input.

    TYPES:
      "! <p class="shorttext">Choose class and structure</p>
      BEGIN OF input,
        "! $required
        "! <p class="shorttext">Class name</p>
        class     TYPE string,
        "! $required
        "! <p class="shorttext">Structure</p>
        structure TYPE string,
      END OF input.
ENDCLASS.


CLASS zcl_mia_consumption_input IMPLEMENTATION.
  METHOD if_aia_sd_action_input~create_input_config.
    DATA input TYPE input.

    DATA(configuration) = ui_information_factory->get_configuration_factory( )->create_for_data( input ).

    configuration->get_element( `class` )->set_types( VALUE #( ( `CLAS/OC` ) ) ).
    configuration->get_element( 'structure' )->set_values( if_sd_config_element=>values_kind-domain_specific_named_items ).

    RETURN ui_information_factory->for_abap_type( abap_type     = input
                                                  configuration = configuration ).
  ENDMETHOD.


  METHOD if_aia_sd_action_input~get_value_help_provider.
    result = cl_sd_value_help_provider=>create( NEW zcl_mia_consumption_value( ) ).
  ENDMETHOD.
ENDCLASS.
