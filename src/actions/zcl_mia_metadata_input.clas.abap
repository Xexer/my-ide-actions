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
    CONSTANTS hide_button       TYPE string VALUE 'HIDE'.
    CONSTANTS qualifier_general TYPE string VALUE 'GENERAL'.

    "! Get the initial fields from the CDS as list
    "! @parameter name   | Name of the CDS
    "! @parameter result | List of fields
    METHODS get_fields_for_cds
      IMPORTING !name         TYPE string
      RETURNING VALUE(result) TYPE fields.

    "! Get the initial facets for this CDS
    "! @parameter name   | Name of the CDS
    "! @parameter result | List of facets
    METHODS get_facets_for_cds
      IMPORTING !name         TYPE string
      RETURNING VALUE(result) TYPE facets.

    "! Harmonize Composition to ID
    "! @parameter alias  | Alias for the composition
    "! @parameter result | ID for Facet
    METHODS harmonize_id
      IMPORTING !alias        TYPE sxco_ddef_alias_name
      RETURNING VALUE(result) TYPE string.
ENDCLASS.


CLASS zcl_mia_metadata_input IMPLEMENTATION.
  METHOD if_aia_sd_action_input~create_input_config.
    DATA input TYPE input.

    IF context IS BOUND.
      DATA(focused_object) = context->get_focused_resource( ).
      input-core_data_service = focused_object->get_name( ).
      input-facets            = get_facets_for_cds( input-core_data_service ).
      input-fields            = get_fields_for_cds( input-core_data_service ).
    ENDIF.

    DATA(configuration) = ui_information_factory->get_configuration_factory( )->create_for_data( input ).
    configuration->set_layout( type = if_sd_config_element=>layout-grid ).

    DATA(facet_table) = configuration->get_structured_table( 'facets' ).
    facet_table->set_layout( if_sd_config_element=>layout-table ).
    DATA(facet_line) = facet_table->get_line_structure( ).
    facet_line->get_element( `old` )->set_hidden( ).
    facet_line->set_sideeffect( after_update = abap_true ).

    DATA(field_table) = configuration->get_structured_table( 'fields' ).
    field_table->set_layout( if_sd_config_element=>layout-table ).
    field_table->set_actions( VALUE #( ( kind = if_sd_actions=>kind-model id = hide_button title = 'Hide' ) ) ).

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


  METHOD get_fields_for_cds.
    DATA(cds) = xco_cp_cds=>view_entity( CONV #( name ) ).
    IF NOT cds->exists( ).
      RETURN.
    ENDIF.

    DATA(lineitem) = 10.
    DATA(identification) = 10.
    DATA(selection) = 10.

    LOOP AT cds->fields->all->get( ) INTO DATA(field).
      INSERT VALUE #( ) INTO TABLE result REFERENCE INTO DATA(actual).
      DATA(content) = field->content( )->get( ).

      IF content-alias IS NOT INITIAL.
        actual->name = content-alias.
      ELSEIF content-original_name IS NOT INITIAL.
        actual->name = content-original_name.
      ENDIF.

      actual->qualifier          = qualifier_general.
      actual->pos_identification = identification.
      identification += 10.

      actual->pos_lineitem = lineitem.
      lineitem += 10.

      IF content-key_indicator = abap_true.
        actual->pos_selection = selection.
        selection += 10.
      ENDIF.
    ENDLOOP.

    DELETE result WHERE name IS INITIAL.
  ENDMETHOD.


  METHOD get_facets_for_cds.
    DATA(cds) = xco_cp_cds=>view_entity( CONV #( name ) ).
    IF NOT cds->exists( ).
      RETURN.
    ENDIF.

    INSERT VALUE #( ) INTO TABLE result REFERENCE INTO DATA(actual).
    actual->id               = `idGeneral`.
    actual->label            = `General Information`.
    actual->type             = facet_types-identification.
    actual->target_qualifier = qualifier_general.
    actual->position         = 10.
    actual->old              = actual->target_qualifier.

    DATA(position) = 20.

    LOOP AT cds->compositions->all->get( ) INTO DATA(composition).
      DATA(alias) = composition->content( )->get_alias( ).

      IF line_exists( result[ target_element = alias ] ).
        CONTINUE.
      ENDIF.

      INSERT VALUE #( ) INTO TABLE result REFERENCE INTO actual.
      actual->id             = harmonize_id( alias ).
      actual->type           = facet_types-lineitem.
      actual->target_element = composition->content( )->get_alias( ).
      actual->position       = position.
      position += 10.
    ENDLOOP.
  ENDMETHOD.


  METHOD harmonize_id.
    DATA(local_id) = alias.
    IF substring( val = local_id
                  len = 1 ) = `_`.
      local_id = substring( val = local_id
                            off = 1 ).
    ENDIF.

    RETURN |id{ local_id }|.
  ENDMETHOD.
ENDCLASS.
