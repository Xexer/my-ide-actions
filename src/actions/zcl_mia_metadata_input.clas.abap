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
    METHODS get_fields_for_cds
      IMPORTING !name         TYPE string
      RETURNING VALUE(result) TYPE fields.

    METHODS get_facets_for_cds
      IMPORTING !name         TYPE string
      RETURNING VALUE(result) TYPE facets.
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

    DATA(field_table) = configuration->get_structured_table( 'fields' ).
    field_table->set_layout( if_sd_config_element=>layout-table ).

    RETURN ui_information_factory->for_abap_type( abap_type     = input
                                                  configuration = configuration ).
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

      actual->qualifier          = 'GENERAL'.
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
    actual->label            = `General Informations`.
    actual->type             = facet_types-identification.
    actual->target_qualifier = `GENERAL`.
    actual->position         = 10.

    DATA(position) = 20.

    LOOP AT cds->compositions->all->get( ) INTO DATA(composition).
      INSERT VALUE #( ) INTO TABLE result REFERENCE INTO actual.
      actual->id             = `idRef`.
      actual->type           = facet_types-lineitem.
      actual->target_element = composition->content( )->get_alias( ).
      actual->position       = position.
      position += 10.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
