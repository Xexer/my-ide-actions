CLASS zcl_mia_metadata_input DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_sd_action_input.

    CONSTANTS:
      BEGIN OF facet_types,
        "! <p class="shorttext">Identification</p>
        identification TYPE string VALUE `IDENT`,
        "! <p class="shorttext">FieldGroup</p>
        fieldgroup     TYPE string VALUE `FGROUP`,
        "! <p class="shorttext">LineItem</p>
        lineitem       TYPE string VALUE `LINEITEM`,
      END OF facet_types.

    "! $values { @link zcl_mia_metadata_input.data:facet_types }
    "! $default { @link zcl_mia_metadata_input.data:facet_types.identification }
    TYPES facet_type TYPE string.

    TYPES:
      BEGIN OF facet,
        "! <p class="shorttext">ID</p>
        id               TYPE string,
        "! <p class="shorttext">Parent ID</p>
        parent_id        TYPE string,
        "! <p class="shorttext">Label</p>
        label            TYPE string,
        "! <p class="shorttext">Type</p>
        type             TYPE facet_type,
        "! <p class="shorttext">Position</p>
        position         TYPE string,
        "! <p class="shorttext">Qualifier</p>
        target_qualifier TYPE string,
        "! <p class="shorttext">Reference</p>
        target_element   TYPE string,
        "! <p class="shorttext">Field to Hide</p>
        hide_facet       TYPE string,
        old              TYPE string,
      END OF facet.
    TYPES facets TYPE STANDARD TABLE OF facet WITH EMPTY KEY.

    TYPES:
      BEGIN OF field,
        "! <p class="shorttext">Field</p>
        name               TYPE string,
        "! <p class="shorttext">New Label</p>
        label              TYPE string,
        "! <p class="shorttext">Selection [P]</p>
        pos_selection      TYPE string,
        "! <p class="shorttext">LineItem [P]</p>
        pos_lineitem       TYPE string,
        "! <p class="shorttext">Identification [P]</p>
        pos_identification TYPE string,
        "! <p class="shorttext">FieldGroup [P]</p>
        pos_fieldgroup     TYPE string,
        "! <p class="shorttext">Qualifier</p>
        qualifier          TYPE string,
        "! <p class="shorttext">Field to Hide</p>
        hide_field         TYPE string,
      END OF field.
    TYPES fields TYPE STANDARD TABLE OF field WITH EMPTY KEY.

    TYPES:
      "! <p class="shorttext">Core Data Service</p>
      BEGIN OF input,
        core_data_service TYPE string,
        facets            TYPE facets,
        fields            TYPE fields,
      END OF input.

  PRIVATE SECTION.
    CONSTANTS hide_button TYPE string VALUE 'HIDE'.
ENDCLASS.


CLASS zcl_mia_metadata_input IMPLEMENTATION.
  METHOD if_aia_sd_action_input~create_input_config.
    DATA input TYPE input.

    IF context IS BOUND.
      DATA(focused_object) = context->get_focused_resource( ).
      DATA(resource) = CAST if_adt_context_src_based_obj( context->get_focused_resource( ) ).
      DATA(metadata) = zcl_mia_core_factory=>create_metadata( ).

      TRY.
          DATA(source_code) = resource->get_source_code( ).
        CATCH cx_adt_context_dynamic cx_adt_context_unauthorized.
          CLEAR source_code.
      ENDTRY.

      input = metadata->parse_source_code_to_input( core_data_service = focused_object->get_name( )
                                                    code              = source_code ).
    ENDIF.

    DATA(configuration) = ui_information_factory->get_configuration_factory( )->create_for_data( input ).
    configuration->set_layout( type = if_sd_config_element=>layout-grid ).
    configuration->get_element( `core_data_service` )->set_read_only( ).

    DATA(facet_table) = configuration->get_structured_table( 'facets' ).
    facet_table->set_layout( if_sd_config_element=>layout-table ).
    DATA(facet_line) = facet_table->get_line_structure( ).
    facet_line->get_element( `old` )->set_hidden( ).
    facet_line->set_sideeffect( after_update = abap_true ).
    facet_line->get_element( `hide_facet` )->set_values( if_sd_config_element=>values_kind-domain_specific_named_items ).

    DATA(field_table) = configuration->get_structured_table( 'fields' ).
    field_table->set_layout( if_sd_config_element=>layout-table ).
    field_table->set_actions( VALUE #( ( kind = if_sd_actions=>kind-model id = hide_button title = 'Hide' ) ) ).
    DATA(field_line) = field_table->get_line_structure( ).
    field_line->get_element( `hide_field` )->set_values( if_sd_config_element=>values_kind-domain_specific_named_items ).

    RETURN ui_information_factory->for_abap_type( abap_type     = input
                                                  configuration = configuration ).
  ENDMETHOD.


  METHOD if_aia_sd_action_input~get_side_effect_provider.
    RETURN cl_sd_sideeffect_provider=>create( determination = NEW zcl_mia_metadata_side_effect( ) ).
  ENDMETHOD.


  METHOD if_aia_sd_action_input~get_action_provider.
    RETURN cl_sd_action_provider=>create(
        VALUE #( ( kind = if_sd_actions=>kind-model id = hide_button handler = 'ZCL_MIA_METADATA_HIDE' ) ) ).
  ENDMETHOD.


  METHOD if_aia_sd_action_input~get_value_help_provider.
    result = cl_sd_value_help_provider=>create( NEW zcl_mia_metadata_value( ) ).
  ENDMETHOD.
ENDCLASS.
