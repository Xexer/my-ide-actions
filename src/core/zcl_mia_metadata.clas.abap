CLASS zcl_mia_metadata DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_mia_metadata.

  PRIVATE SECTION.
    DATA input TYPE zif_mia_metadata=>metadata_input.
    DATA code  TYPE string_table.

    "! Add the line to the complete code list
    "! @parameter code_line | One Line of code
    METHODS add_code
      IMPORTING code_line TYPE string.

    "! Generate a facet
    "! @parameter facet | Settings for Facet
    "! @parameter actual_tabix |
    METHODS generate_facet
      IMPORTING facet        TYPE zif_mia_metadata=>facet
                actual_tabix TYPE i.

    "! Generate a field
    "! @parameter field | Settings for Field
    METHODS generate_field
      IMPORTING !field TYPE zif_mia_metadata=>field.
ENDCLASS.


CLASS zcl_mia_metadata IMPLEMENTATION.
  METHOD zif_mia_metadata~generate_metadata_code.
    me->input = input.
    CLEAR code.

    add_code( |@UI.facet: [| ).
    LOOP AT input-facets INTO DATA(facet).
      DATA(actual_tabix) = sy-tabix.
      generate_facet( facet        = facet
                      actual_tabix = actual_tabix ).
    ENDLOOP.
    add_code( |]\n| ).

    LOOP AT input-fields INTO DATA(field).
      generate_field( field ).
      add_code( |{ field-name };| ).
      add_code( `` ).
    ENDLOOP.

    RETURN xco_cp=>strings( code )->join( |\n| )->value.
  ENDMETHOD.


  METHOD add_code.
    INSERT code_line INTO TABLE code.
  ENDMETHOD.


  METHOD generate_facet.
    " TODO: parameter ACTUAL_TABIX is never used (ABAP cleaner)

    DATA(spaces) = `    `.
    add_code( `  {` ).

    IF facet-id IS NOT INITIAL.
      add_code( |{ spaces }id: '{ facet-id }',| ).
    ENDIF.

    IF facet-label IS NOT INITIAL.
      add_code( |{ spaces }label: '{ facet-label }',| ).
    ENDIF.

    IF facet-position IS NOT INITIAL.
      add_code( |{ spaces }position: '{ facet-position }',| ).
    ENDIF.

    IF facet-type IS NOT INITIAL.
      DATA(type) = SWITCH #( facet-type
                             WHEN zcl_mia_metadata_input=>facet_types-identification THEN `#IDENTIFICATION_REFERENCE`
                             WHEN zcl_mia_metadata_input=>facet_types-fieldgroup     THEN `#FIELDGROUP_REFERENCE`
                             WHEN zcl_mia_metadata_input=>facet_types-lineitem       THEN `#LINEITEM_REFERENCE` ).
      add_code( |{ spaces }type: { type },| ).
    ENDIF.

    IF facet-target_qualifier IS NOT INITIAL.
      add_code( |{ spaces }targetQualifier: '{ facet-target_qualifier }',| ).
    ENDIF.

    IF facet-target_element IS NOT INITIAL.
      add_code( |{ spaces }targetElement: '{ facet-target_element }',| ).
    ENDIF.

    add_code( `  }` ).
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

    IF field-pos_selection IS NOT INITIAL.
      add_code( |@UI.selectionField: [ \{ position: { field-pos_selection } \} ]| ).
    ENDIF.

    IF field-pos_lineitem IS NOT INITIAL.
      add_code( |@UI.lineItem: [ \{ position: { field-pos_lineitem } \} ]| ).
    ENDIF.

    IF field-pos_identification IS NOT INITIAL.
      add_code( |@UI.identification: [ \{ position: { field-pos_identification }{ qualifier } \} ]| ).
    ENDIF.

    IF field-pos_fieldgroup IS NOT INITIAL.
      add_code( |@UI.fieldGroup: [ \{ position: { field-pos_fieldgroup }{ qualifier } \} ]| ).
    ENDIF.

    IF field-label IS NOT INITIAL.
      add_code( |@EndUserText.label: '{ field-label }'| ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
