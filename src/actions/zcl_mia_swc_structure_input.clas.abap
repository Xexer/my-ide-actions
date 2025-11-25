CLASS zcl_mia_swc_structure_input DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_sd_action_input.

    TYPES:
      "! <p class="shorttext">New packages</p>
      BEGIN OF generated_packages,
        "! <p class="shorttext">Create APP package</p>
        x_app   TYPE abap_boolean,
        "! <p class="shorttext">App #1</p>
        app_1   TYPE string,
        "! <p class="shorttext">App #2</p>
        app_2   TYPE string,
        "! <p class="shorttext">App #3</p>
        app_3   TYPE string,
        "! <p class="shorttext">Create INTF package</p>
        x_intf  TYPE abap_boolean,
        "! <p class="shorttext">Interface #1</p>
        intf_1  TYPE string,
        "! <p class="shorttext">Interface #2</p>
        intf_2  TYPE string,
        "! <p class="shorttext">Interface #3</p>
        intf_3  TYPE string,
        "! <p class="shorttext">Create FIORI package</p>
        x_fiori TYPE abap_boolean,
        "! <p class="shorttext">Create REUSE package</p>
        x_reuse TYPE abap_boolean,
        "! <p class="shorttext">Create SHARE package</p>
        x_share TYPE abap_boolean,
        "! <p class="shorttext">Create TEST package</p>
        x_test  TYPE abap_boolean,
      END OF generated_packages.

    TYPES:
      "! <p class="shorttext">Create new class</p>
      BEGIN OF input,
        "! $required
        "! $maxLength 30
        package   TYPE sxco_package,
        "! $maxLength 20
        transport TYPE sxco_transport,
        objects   TYPE generated_packages,
      END OF input.

  PRIVATE SECTION.
    "! Read the transport for the object
    "! @parameter input  | Input from action
    "! @parameter result | Transport number
    METHODS get_transport_for_object
      IMPORTING !input        TYPE input
      RETURNING VALUE(result) TYPE input-transport.
ENDCLASS.


CLASS zcl_mia_swc_structure_input IMPLEMENTATION.
  METHOD if_aia_sd_action_input~create_input_config.
    DATA input TYPE input.

    IF context IS BOUND.
      DATA(focused_object) = context->get_focused_resource( ).
      input-package   = focused_object->get_name( ).
      input-transport = get_transport_for_object( input ).
*      input-objects-x_app   = abap_true.
*      input-objects-x_fiori = abap_true.
*      input-objects-x_intf  = abap_true.
*      input-objects-x_reuse = abap_true.
*      input-objects-x_share = abap_true.
    ENDIF.

    DATA(configuration) = ui_information_factory->get_configuration_factory( )->create_for_data( input ).
    configuration->set_layout( if_sd_config_element=>layout-grid ).
    configuration->get_element( `PACKAGE` )->set_read_only( ).

    RETURN ui_information_factory->for_abap_type( abap_type     = input
                                                  configuration = configuration ).
  ENDMETHOD.


  METHOD get_transport_for_object.
    TRY.
        RETURN xco_cp_abap_repository=>package->for( input-package )->if_xco_cts_changeable~get_object( )->get_lock( )->get_transport( ).
      CATCH cx_root.
        RETURN ''.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
