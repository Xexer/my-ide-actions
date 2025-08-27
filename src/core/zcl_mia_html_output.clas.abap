CLASS zcl_mia_html_output DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_mia_html_output.

  PRIVATE SECTION.
    CONSTANTS depth_level_sign TYPE string VALUE '➥'.

    DATA output TYPE string.

    TYPES: BEGIN OF rap_output,
             layer    TYPE string,
             object   TYPE string,
             behavior TYPE string,
             metadata TYPE string,
           END OF rap_output.
    TYPES rap_outputs TYPE STANDARD TABLE OF rap_output WITH EMPTY KEY.

    TYPES: BEGIN OF rap_hierarchy,
             level  TYPE i,
             object TYPE string,
           END OF rap_hierarchy.
    TYPES rap_hierarchies TYPE STANDARD TABLE OF rap_hierarchy WITH EMPTY KEY.

    "! Build HTML Header
    "! @parameter text | Text for Header
    METHODS generate_header
      IMPORTING !text TYPE string.

    "! Build HTML Text
    "! @parameter text | Text
    METHODS generate_text
      IMPORTING !text TYPE string.

    "! Create HTML Breaks
    "! @parameter number | Number of breaks
    METHODS generate_break
      IMPORTING !number TYPE i DEFAULT 1.

    "! Build HTML Table from generic data
    "! @parameter generic_data | Data
    METHODS generate_table
      IMPORTING generic_data TYPE REF TO data.

    "! Create Result-Object table
    "! @parameter generation_result | Result from Run
    METHODS build_object_table
      IMPORTING generation_result TYPE zif_mia_object_generator=>generation_result.

    "! Create Error-Object table
    "! @parameter generation_result | Result from Run
    METHODS build_error_table
      IMPORTING generation_result TYPE zif_mia_object_generator=>generation_result.

    "! Finalize HTML Document
    "! @parameter result | HTML Document
    METHODS finalize_document
      RETURNING VALUE(result) TYPE string.

    "! Create Message-Object table
    "! @parameter generation_result | Result from Run
    METHODS build_message_table
      IMPORTING generation_result TYPE zif_mia_object_generator=>generation_result.

    "! Build node hierarchy for HTML output
    "! @parameter hierarchies | Hierarchies
    "! @parameter object_type | Type of object
    "! @parameter result      | HTML output
    METHODS build_rap_hierarchy
      IMPORTING hierarchies   TYPE rap_hierarchies
                object_type   TYPE string
      RETURNING VALUE(result) TYPE string.

    "! Build index table in real order
    "! @parameter field  | Name of the field
    "! @parameter layer  | Actual layer
    "! @parameter result | Index table
    METHODS build_hierarchy_index_table
      IMPORTING !field        TYPE string
                layer         TYPE zif_mia_rap_analyzer=>rap_layer
      RETURNING VALUE(result) TYPE rap_hierarchies.

    "! Build index table one layer deeper
    "! @parameter depth         | Index for depth
    "! @parameter actual_entity | Actual RAP node
    "! @parameter field         | Name of the field
    "! @parameter layer         | Actual layer
    "! @parameter result        | Index table
    METHODS build_index_layer
      IMPORTING !depth        TYPE i
                actual_entity TYPE string
                !field        TYPE string
                layer         TYPE zif_mia_rap_analyzer=>rap_layer
      CHANGING  !result       TYPE zcl_mia_html_output=>rap_hierarchies.
ENDCLASS.


CLASS zcl_mia_html_output IMPLEMENTATION.
  METHOD zif_mia_html_output~generate_html_output.
    CLEAR output.

    generate_header( |{ TEXT-001 } [{ generation_result-transport }]| ).
    build_message_table( generation_result ).
    build_error_table( generation_result ).
    build_object_table( generation_result ).

    RETURN finalize_document( ).
  ENDMETHOD.


  METHOD zif_mia_html_output~generate_generic_output.
    CLEAR output.

    generate_table( table ).

    RETURN finalize_document( ).
  ENDMETHOD.


  METHOD zif_mia_html_output~generate_rap_object.
    DATA rap_output             TYPE rap_outputs.
    DATA rap_hierarchy_objects  TYPE rap_hierarchies.
    DATA rap_hierarchy_metadata TYPE rap_hierarchies.

    CLEAR output.
    DATA(link) = zcl_mia_core_factory=>create_object_link( ).

    INSERT VALUE #( layer    = 'Layer'
                    object   = 'Objects'
                    behavior = 'Behavior'
                    metadata = 'Metadata' )
           INTO TABLE rap_output.

    INSERT VALUE #( layer    = '<strong>Service Binding</strong>'
                    object   = link->get_hmtl_link_for_object( object_type = link->supported_objects-service_binding
                                                               object      = object-service_binding )
                    behavior = ''
                    metadata = '' )
           INTO TABLE rap_output.

    INSERT VALUE #( layer    = '<strong>Service Definition</strong>'
                    object   = link->get_hmtl_link_for_object( object_type = link->supported_objects-service_definition
                                                               object      = object-service_definition )
                    behavior = ''
                    metadata = '' )
           INTO TABLE rap_output.

    rap_hierarchy_objects = build_hierarchy_index_table( field = `CDS_ENTITY`
                                                         layer = object-consumption ).

    rap_hierarchy_metadata = build_hierarchy_index_table( field = `METADATA`
                                                          layer = object-consumption ).

    INSERT VALUE #( layer    = '<strong>Consumption</strong>'
                    object   = build_rap_hierarchy( hierarchies = rap_hierarchy_objects
                                                    object_type = zif_mia_object_link=>supported_objects-cds )
                    behavior = link->get_hmtl_link_for_object( object_type = link->supported_objects-behavior
                                                               object      = object-consumption-behavior )
                    metadata = build_rap_hierarchy( hierarchies = rap_hierarchy_metadata
                                                    object_type = zif_mia_object_link=>supported_objects-metadata ) )
           INTO TABLE rap_output.

    rap_hierarchy_objects = build_hierarchy_index_table( field = `CDS_ENTITY`
                                                         layer = object-base ).

    rap_hierarchy_metadata = build_hierarchy_index_table( field = `METADATA`
                                                          layer = object-base ).

    INSERT VALUE #( layer    = '<strong>Interface</strong>'
                    object   = build_rap_hierarchy( hierarchies = rap_hierarchy_objects
                                                    object_type = zif_mia_object_link=>supported_objects-cds )
                    behavior = link->get_hmtl_link_for_object( object_type = link->supported_objects-behavior
                                                               object      = object-base-behavior )
                    metadata = build_rap_hierarchy( hierarchies = rap_hierarchy_metadata
                                                    object_type = zif_mia_object_link=>supported_objects-metadata ) )
           INTO TABLE rap_output.

    rap_hierarchy_objects = build_hierarchy_index_table( field = `TABLE`
                                                         layer = object-base ).

    INSERT VALUE #(
        layer    = '<strong>Database</strong>'
        object   = build_rap_hierarchy( hierarchies = rap_hierarchy_objects
                                        object_type = zif_mia_object_link=>supported_objects-database_table )
        behavior = ''
        metadata = '' )
           INTO TABLE rap_output.

    DATA(domains) = ``.
    LOOP AT object-domains INTO DATA(domain).
      IF domains IS NOT INITIAL.
        domains &&= `<br>`.
      ENDIF.

      domains &&= link->get_hmtl_link_for_object( object_type = link->supported_objects-domain
                                                  object      = domain ).
    ENDLOOP.

    INSERT VALUE #( layer    = '<strong>Domain</strong>'
                    object   = domains
                    behavior = ''
                    metadata = '' )
           INTO TABLE rap_output.

    DATA(rap_pattern) = SWITCH #( object-classification
                                  WHEN zif_mia_rap_analyzer=>classifications-standard THEN `Classic Pattern`
                                  WHEN zif_mia_rap_analyzer=>classifications-custom   THEN `Custom Pattern` ).

    generate_header( object-name ).
    generate_text( rap_pattern ).
    generate_table( REF #( rap_output ) ).

    RETURN finalize_document( ).
  ENDMETHOD.


  METHOD build_hierarchy_index_table.
    ASSIGN COMPONENT field OF STRUCTURE layer TO FIELD-SYMBOL(<content>).
    INSERT VALUE #( level  = 1
                    object = <content> ) INTO TABLE result.

    build_index_layer( EXPORTING depth         = 2
                                 actual_entity = layer-cds_entity
                                 field         = field
                                 layer         = layer
                       CHANGING  result        = result ).
  ENDMETHOD.


  METHOD build_index_layer.
    LOOP AT layer-childs INTO DATA(child) WHERE parent_child = actual_entity.
      ASSIGN COMPONENT field OF STRUCTURE child TO FIELD-SYMBOL(<content>).
      INSERT VALUE #( level  = depth
                      object = <content> ) INTO TABLE result.

      build_index_layer( EXPORTING depth         = depth + 1
                                   actual_entity = child-cds_entity
                                   field         = field
                                   layer         = layer
                         CHANGING  result        = result ).
    ENDLOOP.
  ENDMETHOD.


  METHOD build_rap_hierarchy.
    DATA(link) = zcl_mia_core_factory=>create_object_link( ).

    LOOP AT hierarchies INTO DATA(hierarchy) WHERE object IS NOT INITIAL.
      DATA(object_link) = link->get_hmtl_link_for_object( object_type = object_type
                                                          object      = hierarchy-object ).

      IF result IS NOT INITIAL.
        result &&= `<br>`.
      ENDIF.

      DO hierarchy-level - 1 TIMES.
        result &&= depth_level_sign.
      ENDDO.
      result &&= | { object_link }|.
    ENDLOOP.
  ENDMETHOD.


  METHOD build_object_table.
    DATA(link_factory) = zcl_mia_core_factory=>create_object_link( ).
    DATA(link) = ``.

    DATA(objects) = VALUE zif_mia_html_output=>generated_objects( ( object_type = TEXT-006 name = TEXT-007 ) ).

    IF generation_result-interface IS NOT INITIAL.
      link = link_factory->get_hmtl_link_for_object( object_type = link_factory->supported_objects-interface
                                                     object      = generation_result-interface ).
      INSERT VALUE #( object_type = TEXT-002
                      name        = link ) INTO TABLE objects.
    ENDIF.

    IF generation_result-class IS NOT INITIAL.
      link = link_factory->get_hmtl_link_for_object( object_type = link_factory->supported_objects-class
                                                     object      = generation_result-class ).
      INSERT VALUE #( object_type = TEXT-003
                      name        = link ) INTO TABLE objects.
    ENDIF.

    IF generation_result-factory IS NOT INITIAL.
      link = link_factory->get_hmtl_link_for_object( object_type = link_factory->supported_objects-class
                                                     object      = generation_result-factory ).
      INSERT VALUE #( object_type = TEXT-004
                      name        = link ) INTO TABLE objects.
    ENDIF.

    IF generation_result-injector IS NOT INITIAL.
      link = link_factory->get_hmtl_link_for_object( object_type = link_factory->supported_objects-class
                                                     object      = generation_result-injector ).
      INSERT VALUE #( object_type = TEXT-005
                      name        = link ) INTO TABLE objects.
    ENDIF.

    generate_table( REF #( objects ) ).
  ENDMETHOD.


  METHOD generate_table.
    DATA table_result TYPE string.
    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>  TYPE any.

    ASSIGN generic_data->* TO <table>.
    DATA(header) = abap_true.

    IF lines( <table> ) > 1.
      generate_break( ).
    ELSE.
      RETURN.
    ENDIF.

    LOOP AT <table> ASSIGNING <line>.
      table_result &&= `<tr>`.

      DO.
        DATA(index) = sy-index.
        ASSIGN COMPONENT index OF STRUCTURE <line> TO FIELD-SYMBOL(<field>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        IF header = abap_true.
          table_result &&= |<th>{ <field> }</th>|.
        ELSE.
          table_result &&= |<td>{ <field> }</td>|.
        ENDIF.
      ENDDO.

      table_result &&= `</tr>`.
      header = abap_false.
    ENDLOOP.

    output &&= |<table>{ table_result }</table>|.
  ENDMETHOD.


  METHOD generate_header.
    output &&= |<h1>{ text }</h1>|.
  ENDMETHOD.


  METHOD build_error_table.
    IF generation_result-findings IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(errors) = VALUE zif_mia_html_output=>generated_errors( ( object_name = TEXT-007 message = TEXT-009 ) ).

    LOOP AT generation_result-findings->get( ) INTO DATA(message).
      INSERT VALUE #( object_name = message->object_name
                      message     = message->message->get_text( ) ) INTO TABLE errors.
    ENDLOOP.

    generate_table( REF #( errors ) ).
  ENDMETHOD.


  METHOD generate_break.
    DO number TIMES.
      output &&= |<br>|.
    ENDDO.
  ENDMETHOD.


  METHOD finalize_document.
    DATA(css) = `table { border-collapse: collapse; } `.
    css &&= `td, th { padding: 10px 17px; line-height: 2.0; } `.
    css &&= |td, th \{ border: 1px solid grey; \} |.
    css &&= |th \{ background-color: black; color: white; \} |.

    RETURN |<!DOCTYPE html lang="en">| &
           |<head>| &
           |  <style>| &
           |    { css }| &
           |  </style>| &
           |</head>| &
           |<body>| &
           |  { output }| &
           |</body>| &
           |</html>|.
  ENDMETHOD.


  METHOD build_message_table.
    DATA(errors) = VALUE zif_mia_html_output=>generated_errors( ( object_name = TEXT-007 message = TEXT-009 ) ).

    LOOP AT generation_result-messages INTO DATA(message).
      INSERT VALUE #( object_name = TEXT-010
                      message     = message->get_text( ) ) INTO TABLE errors.
    ENDLOOP.

    generate_table( REF #( errors ) ).
  ENDMETHOD.


  METHOD generate_text.
    output &&= |<p>{ text }</p>|.
  ENDMETHOD.
ENDCLASS.
