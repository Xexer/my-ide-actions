CLASS zcl_mia_metadata DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_mia_metadata.

  PRIVATE SECTION.
    CONSTANTS qualifier_general TYPE string VALUE 'GENERAL'.

    "! Input from the UI action
    DATA input TYPE zif_mia_metadata=>metadata_input.

    "! Local code for output
    DATA code  TYPE string_table.

    "! Add the line to the complete code list
    "! @parameter code_line | One Line of code
    METHODS add_code
      IMPORTING code_line TYPE string.

    "! Generate a facet
    "! @parameter facet            | Settings for Facet
    "! @parameter global_separator | Separator for full item
    METHODS generate_facet
      IMPORTING facet            TYPE zif_mia_metadata=>facet
                global_separator TYPE string.

    "! Generate a field
    "! @parameter field | Settings for Field
    METHODS generate_field
      IMPORTING !field TYPE zif_mia_metadata=>field.

    "! Get the initial fields from the CDS as list
    "! @parameter name   | Name of the CDS
    "! @parameter result | List of fields
    METHODS get_fields_for_cds
      IMPORTING !name         TYPE string
      RETURNING VALUE(result) TYPE zcl_mia_metadata_input=>fields.

    "! Get the initial facets for this CDS
    "! @parameter name   | Name of the CDS
    "! @parameter result | List of facets
    METHODS get_facets_for_cds
      IMPORTING !name         TYPE string
      RETURNING VALUE(result) TYPE zcl_mia_metadata_input=>facets.

    "! Harmonize Composition to ID
    "! @parameter alias  | Alias for the composition
    "! @parameter result | ID for Facet
    METHODS harmonize_id
      IMPORTING !alias        TYPE sxco_ddef_alias_name
      RETURNING VALUE(result) TYPE string.

    METHODS analyze_metadata_code
      IMPORTING !code TYPE string_table.
ENDCLASS.


CLASS zcl_mia_metadata IMPLEMENTATION.
  METHOD zif_mia_metadata~generate_metadata_code.
    me->input = input.
    CLEAR code.

    add_code( |@UI.facet: [| ).
    LOOP AT input-facets INTO DATA(facet).
      DATA(separator) = ``.
      IF sy-tabix <> lines( input-facets ).
        separator = `,`.
      ENDIF.

      generate_facet( facet            = facet
                      global_separator = separator ).
    ENDLOOP.
    add_code( |]\n| ).

    LOOP AT input-fields INTO DATA(field).
      generate_field( field ).
      add_code( |{ field-name };| ).
      add_code( `` ).
    ENDLOOP.

    RETURN xco_cp=>strings( code )->join( |\n| )->value.
  ENDMETHOD.


  METHOD zif_mia_metadata~parse_source_code_to_input.
    input = VALUE #( core_data_service = core_data_service ).

    analyze_metadata_code( code ).

    IF input-facets IS INITIAL.
      input-facets = get_facets_for_cds( input-core_data_service ).
    ENDIF.

    IF input-fields IS INITIAL.
      input-fields = get_fields_for_cds( input-core_data_service ).
    ENDIF.

    RETURN input.
  ENDMETHOD.


  METHOD add_code.
    INSERT code_line INTO TABLE code.
  ENDMETHOD.


  METHOD generate_facet.
    DATA local_code TYPE string_table.

    IF facet-id IS NOT INITIAL.
      INSERT |id: '{ facet-id }'| INTO TABLE local_code.
    ENDIF.

    IF facet-label IS NOT INITIAL.
      INSERT |label: '{ facet-label }'| INTO TABLE local_code.
    ENDIF.

    IF facet-position IS NOT INITIAL.
      INSERT |position: '{ facet-position }'| INTO TABLE local_code.
    ENDIF.

    IF facet-type IS NOT INITIAL.
      DATA(type) = SWITCH #( facet-type
                             WHEN zcl_mia_metadata_input=>facet_types-identification THEN `#IDENTIFICATION_REFERENCE`
                             WHEN zcl_mia_metadata_input=>facet_types-fieldgroup     THEN `#FIELDGROUP_REFERENCE`
                             WHEN zcl_mia_metadata_input=>facet_types-lineitem       THEN `#LINEITEM_REFERENCE` ).
      INSERT |type: '{ type }'| INTO TABLE local_code.
    ENDIF.

    IF facet-target_qualifier IS NOT INITIAL.
      INSERT |targetQualifier: '{ facet-target_qualifier }'| INTO TABLE local_code.
    ENDIF.

    IF facet-target_element IS NOT INITIAL.
      INSERT |targetElement: '{ facet-target_element }'| INTO TABLE local_code.
    ENDIF.

    IF facet-hide_facet IS NOT INITIAL.
      INSERT |hidden: #({ facet-hide_facet })| INTO TABLE local_code.
    ENDIF.

    add_code( `  {` ).
    LOOP AT local_code INTO DATA(local_line).
      DATA(separator) = ``.
      IF sy-tabix <> lines( local_code ).
        separator = `,`.
      ENDIF.

      add_code( |    { local_line }{ separator }| ).
    ENDLOOP.
    add_code( |  \}{ global_separator }| ).
  ENDMETHOD.


  METHOD generate_field.
    IF     field-pos_fieldgroup IS INITIAL AND field-pos_identification IS INITIAL
       AND field-pos_lineitem   IS INITIAL AND field-pos_selection      IS INITIAL.
      add_code( `@UI.hidden: true` ).
      RETURN.
    ENDIF.

    DATA(qualifier) = ``.
    IF field-qualifier IS NOT INITIAL.
      qualifier = |, qualifier: '{ field-qualifier }'|.
    ENDIF.

    DATA(hidden) = ``.
    IF field-hide_field IS NOT INITIAL.
      hidden = |, hidden: #({ field-hide_field })|.
    ENDIF.

    IF field-pos_selection IS NOT INITIAL.
      add_code( |@UI.selectionField: [ \{ position: { field-pos_selection } \} ]| ).
    ENDIF.

    IF field-pos_lineitem IS NOT INITIAL.
      add_code( |@UI.lineItem: [ \{ position: { field-pos_lineitem }{ hidden } \} ]| ).
    ENDIF.

    IF field-pos_identification IS NOT INITIAL.
      add_code( |@UI.identification: [ \{ position: { field-pos_identification }{ qualifier }{ hidden } \} ]| ).
    ENDIF.

    IF field-pos_fieldgroup IS NOT INITIAL.
      add_code( |@UI.fieldGroup: [ \{ position: { field-pos_fieldgroup }{ qualifier }{ hidden } \} ]| ).
    ENDIF.

    IF field-label IS NOT INITIAL.
      add_code( |@EndUserText.label: '{ field-label }'| ).
    ENDIF.
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
    actual->type             = zcl_mia_metadata_input=>facet_types-identification.
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
      actual->type           = zcl_mia_metadata_input=>facet_types-lineitem.
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


  METHOD analyze_metadata_code.
    IF code IS INITIAL.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
