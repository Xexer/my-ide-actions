CLASS zcl_mia_code_snippet_input DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_sd_action_input.

    CONSTANTS:
      BEGIN OF template_value_table,
        "! <p class="shorttext">-</p>
        empty            TYPE string VALUE '',
        "! <p class="shorttext">Insert change fields</p>
        table_rap_fields TYPE string VALUE 'table_rap_fields',
      END OF template_value_table.

    CONSTANTS:
      BEGIN OF template_value_cds,
        "! <p class="shorttext">-</p>
        empty               TYPE string VALUE '',
        "! <p class="shorttext">Insert change fields</p>
        cds_rap_fields      TYPE string VALUE 'cds_rap_fields',
        "! <p class="shorttext">Value Help from data element</p>
        cds_vh_data_element TYPE string VALUE 'cds_vh_data_element',
        "! <p class="shorttext">Activate dropdown</p>
        cds_vh_dropdown     TYPE string VALUE 'cds_vh_dropdown',
        "! <p class="shorttext">Define Value Help at field</p>
        cds_vh_define       TYPE string VALUE 'cds_vh_define',
      END OF template_value_cds.

    CONSTANTS:
      BEGIN OF template_value_class,
        "! <p class="shorttext">-</p>
        empty TYPE string VALUE '',
      END OF template_value_class.

    CONSTANTS:
      BEGIN OF template_value_behavior,
        "! <p class="shorttext">-</p>
        empty TYPE string VALUE '',
      END OF template_value_behavior.

    "! $values { @link zcl_mia_code_snippet_input.data:template_value_table }
    "! $default { @link zcl_mia_code_snippet_input.data:template_value_table.empty }
    TYPES template_table    TYPE string.

    "! $values { @link zcl_mia_code_snippet_input.data:template_value_cds }
    "! $default { @link zcl_mia_code_snippet_input.data:template_value_cds.empty }
    TYPES template_cds      TYPE string.

    "! $values { @link zcl_mia_code_snippet_input.data:template_value_class }
    "! $default { @link zcl_mia_code_snippet_input.data:template_value_class.empty }
    TYPES template_class    TYPE string.

    "! $values { @link zcl_mia_code_snippet_input.data:template_value_behavior }
    "! $default { @link zcl_mia_code_snippet_input.data:template_value_behavior.empty }
    TYPES template_behavior TYPE string.

    TYPES:
      BEGIN OF setting_field,
        entity       TYPE abap_boolean,
        field        TYPE abap_boolean,
        data_element TYPE abap_boolean,
      END OF setting_field.

    TYPES:
      "! <p class="shorttext">Choose a template</p>
      BEGIN OF input,
        "! $required
        type              TYPE c LENGTH 4,
        "! <p class="shorttext">Template</p>
        template_table    TYPE template_table,
        "! <p class="shorttext">Template</p>
        template_cds      TYPE template_cds,
        "! <p class="shorttext">Template</p>
        template_class    TYPE template_class,
        "! <p class="shorttext">Template</p>
        template_behavior TYPE template_behavior,
        "! <p class="shorttext">CDS Entity</p>
        entity            TYPE string,
        "! <p class="shorttext">Fieldname</p>
        field             TYPE string,
        "! <p class="shorttext">Data Element</p>
        data_element      TYPE string,
      END OF input.
ENDCLASS.


CLASS zcl_mia_code_snippet_input IMPLEMENTATION.
  METHOD if_aia_sd_action_input~create_input_config.
    DATA input   TYPE input.
    DATA setting TYPE setting_field.

    IF context IS BOUND.
      DATA(focused_object) = context->get_focused_resource( ).
      input-type = focused_object->get_type( ).
    ENDIF.

    DATA(configuration) = ui_information_factory->get_configuration_factory( )->create_for_data( input ).
    configuration->set_layout( if_sd_config_element=>layout-selection_detail ).

    configuration->get_element( `type` )->set_read_only( ).
    configuration->get_element( `template_table` )->set_sideeffect( after_update = abap_true ).
    configuration->get_element( `template_cds` )->set_sideeffect( after_update = abap_true ).
    configuration->get_element( `template_class` )->set_sideeffect( after_update = abap_true ).
    configuration->get_element( `template_behavior` )->set_sideeffect( after_update = abap_true ).
*    configuration->get_element( `entity` )->set_types( VALUE #( ( `DDLS/DF` ) ) ).
*    configuration->get_element( `data_element` )->set_types( VALUE #( ( `DTEL/DE` ) ) ).

    CASE input-type.
      WHEN zcl_mia_code_snippet_action=>supported_types-table.
        configuration->get_element( `template_cds` )->set_hidden( ).
        configuration->get_element( `template_class` )->set_hidden( ).
        configuration->get_element( `template_behavior` )->set_hidden( ).

      WHEN zcl_mia_code_snippet_action=>supported_types-cds.
        configuration->get_element( `template_table` )->set_hidden( ).
        configuration->get_element( `template_class` )->set_hidden( ).
        configuration->get_element( `template_behavior` )->set_hidden( ).
        setting-entity       = abap_true.
        setting-field        = abap_true.
        setting-data_element = abap_true.

      WHEN zcl_mia_code_snippet_action=>supported_types-behavior.
        configuration->get_element( `template_table` )->set_hidden( ).
        configuration->get_element( `template_cds` )->set_hidden( ).
        configuration->get_element( `template_class` )->set_hidden( ).

      WHEN zcl_mia_code_snippet_action=>supported_types-class.
        configuration->get_element( `template_table` )->set_hidden( ).
        configuration->get_element( `template_cds` )->set_hidden( ).
        configuration->get_element( `template_behavior` )->set_hidden( ).

    ENDCASE.

    IF setting-entity IS INITIAL.
      configuration->get_element( `entity` )->set_hidden( ).
    ENDIF.

    IF setting-field IS INITIAL.
      configuration->get_element( `field` )->set_hidden( ).
    ENDIF.

    IF setting-data_element IS INITIAL.
      configuration->get_element( `data_element` )->set_hidden( ).
    ENDIF.

    RETURN ui_information_factory->for_abap_type( abap_type     = input
                                                  configuration = configuration ).
  ENDMETHOD.


  METHOD if_aia_sd_action_input~get_side_effect_provider.
    RETURN cl_sd_sideeffect_provider=>create( determination   = NEW zcl_mia_code_snippet_side_eff( )
                                              feature_control = NEW zcl_mia_code_snippet_side_eff( ) ).
  ENDMETHOD.
ENDCLASS.
