CLASS zcl_mia_newclass_input DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_sd_action_input.

    TYPES:
      "! <p class="shorttext">New objects</p>
      BEGIN OF generated_objects,
        "! $required
        "! $maxLength 30
        class     TYPE sxco_ao_object_name,
        "! $maxLength 30
        interface TYPE sxco_ao_object_name,
        "! $maxLength 30
        "! <p class="shorttext">Factory</p>
        factory   TYPE string,
        "! $maxLength 30
        "! <p class="shorttext">Injector</p>
        injector  TYPE string,
      END OF generated_objects.

    TYPES:
      "! <p class="shorttext">Create new class</p>
      BEGIN OF input,
        "! $required
        "! $maxLength 30
        package     TYPE sxco_package,
        "! $required
        "! $maxLength 20
        transport   TYPE sxco_transport,
        "! $required
        "! $maxLength 10
        prefix      TYPE zif_mia_object_generator=>prefix,
        "! $required
        "! $maxLength 24
        name        TYPE sxco_ao_object_name,
        "! $required
        "! $maxLength 50
        description TYPE if_xco_cp_gen_intf_s_form=>tv_short_description,
        "! $required
        "! $maxLength 25
        "! <p class="shorttext">Name of instance</p>
        inst_name   TYPE sxco_ao_object_name,
        "! <p class="shorttext">New objects</p>
        objects     TYPE generated_objects,
      END OF input.

  PRIVATE SECTION.
    "! Lesen des Transports zum Objekt
    "! @parameter input | <p class="shorttext synchronized"></p>
    METHODS get_transport_for_object
      IMPORTING !input        TYPE zcl_mia_newclass_input=>input
      RETURNING VALUE(result) TYPE zcl_mia_newclass_input=>input-transport.

ENDCLASS.


CLASS zcl_mia_newclass_input IMPLEMENTATION.
  METHOD if_aia_sd_action_input~create_input_config.
    DATA input TYPE input.

    IF context IS BOUND.
      DATA(focused_object) = context->get_focused_resource( ).
      input-package   = focused_object->get_name( ).
      input-prefix    = zcl_mia_strings=>get_prefix_from_package( input-package ).
      input-transport = get_transport_for_object( input ).
    ENDIF.

    DATA(configuration) = ui_information_factory->get_configuration_factory( )->create_for_data( input ).
    configuration->set_layout( if_sd_config_element=>layout-grid ).

    configuration->get_element( `PREFIX` )->set_sideeffect( after_update = abap_true ).
    configuration->get_element( `NAME` )->set_sideeffect( after_update = abap_true ).
    configuration->get_element( `PACKAGE` )->set_read_only( ).
    configuration->get_structure( `objects` )->get_element( `factory` )->set_types( VALUE #( ( `CLAS/OC` ) ) ).
    configuration->get_structure( `objects` )->get_element( `injector` )->set_types( VALUE #( ( `CLAS/OC` ) ) ).

    RETURN ui_information_factory->for_abap_type( abap_type     = input
                                                  configuration = configuration ).
  ENDMETHOD.


  METHOD if_aia_sd_action_input~get_side_effect_provider.
    RETURN cl_sd_sideeffect_provider=>create( determination = NEW zcl_mia_newclass_side_effect( ) ).
  ENDMETHOD.


  METHOD get_transport_for_object.
    TRY.
        RETURN xco_cp_abap_repository=>package->for( input-package )->if_xco_cts_changeable~get_object( )->get_lock( )->get_transport( ).
      CATCH cx_root.
        RETURN ''.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
