CLASS zcl_mia_html_rap DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_mia_html_rap.

  PRIVATE SECTION.
    DATA outputs TYPE zif_mia_html_rap=>rap_outputs.
    DATA link    TYPE REF TO zif_mia_object_link.

    "! Build node hierarchy for HTML output
    "! @parameter hierarchies | Hierarchies
    "! @parameter object_type | Type of object
    "! @parameter result      | HTML output
    METHODS build_rap_hierarchy
      IMPORTING hierarchies   TYPE zif_mia_html_rap=>rap_hierarchies
                object_type   TYPE string
      RETURNING VALUE(result) TYPE string.

    "! Build index table in real order
    "! @parameter field  | Name of the field
    "! @parameter layer  | Actual layer
    "! @parameter result | Index table
    METHODS build_hierarchy_index_table
      IMPORTING !field        TYPE string
                layer         TYPE zif_mia_rap_analyzer=>rap_layer
      RETURNING VALUE(result) TYPE zif_mia_html_rap=>rap_hierarchies.

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
      CHANGING  !result       TYPE zif_mia_html_rap=>rap_hierarchies.

    "! Add header to table
    METHODS add_header.

    "! Add Service Binding
    "! @parameter object | RAP Object data
    METHODS add_service_binding
      IMPORTING !object TYPE zif_mia_rap_analyzer=>rap_object.

    "! Add Service Definition
    "! @parameter object | RAP Object data
    METHODS add_service_definition
      IMPORTING !object TYPE zif_mia_rap_analyzer=>rap_object.

    "! Add RAP Layer
    "! @parameter object | RAP Object data
    "! @parameter text   | Text for this layer
    "! @parameter node   | Node for assignment
    METHODS add_hierarchy
      IMPORTING !object TYPE zif_mia_rap_analyzer=>rap_object
                !text   TYPE csequence
                !node   TYPE string.

    "! Add database table
    "! @parameter object | RAP Object data
    METHODS add_table
      IMPORTING !object TYPE zif_mia_rap_analyzer=>rap_object.

    "! Add fixed value domains
    "! @parameter object | RAP Object data
    METHODS add_domains
      IMPORTING !object TYPE zif_mia_rap_analyzer=>rap_object.

    "! Get the formatted layer text
    "! @parameter text   | Text
    "! @parameter result | Formatted Text
    METHODS get_formatted_layer
      IMPORTING !text         TYPE csequence
      RETURNING VALUE(result) TYPE string.

    "! Add to RAP output table
    "! @parameter output | Output structure
    METHODS add_to_output
      IMPORTING !output TYPE zif_mia_html_rap=>rap_output.

    "! Add package entry
    "! @parameter object | RAP Object data
    METHODS add_package
      IMPORTING !object TYPE zif_mia_rap_analyzer=>rap_object.
ENDCLASS.


CLASS zcl_mia_html_rap IMPLEMENTATION.
  METHOD zif_mia_html_rap~generate_rap_object_table.
    CLEAR outputs.
    link = zcl_mia_core_factory=>create_object_link( ).

    add_header( ).
    add_package( object ).
    add_service_binding( object ).
    add_service_definition( object ).

    add_hierarchy( object = object
                   text   = TEXT-001
                   node   = 'CONSUMPTION' ).

    add_hierarchy( object = object
                   text   = TEXT-002
                   node   = 'BASE' ).

    add_table( object ).
    add_domains( object ).

    result-output  = outputs.
    result-pattern = SWITCH #( object-classification
                               WHEN zif_mia_rap_analyzer=>classifications-standard THEN TEXT-003
                               WHEN zif_mia_rap_analyzer=>classifications-custom   THEN TEXT-004 ).
    result-pattern = |<span style="color:#e65100;font-weight:bold">[{ result-pattern }]</span>|.
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
        result &&= zif_mia_html_rap=>depth_level_sign.
      ENDDO.
      result &&= | { object_link }|.
    ENDLOOP.
  ENDMETHOD.


  METHOD add_header.
    add_to_output( VALUE #( layer    = TEXT-005
                            object   = TEXT-006
                            behavior = TEXT-007
                            metadata = TEXT-008 ) ).
  ENDMETHOD.


  METHOD add_service_binding.
    add_to_output( VALUE #(
                       layer    = get_formatted_layer( TEXT-009 )
                       object   = link->get_hmtl_link_for_object( object_type = link->supported_objects-service_binding
                                                                  object      = object-service_binding )
                       behavior = ''
                       metadata = '' ) ).
  ENDMETHOD.


  METHOD add_service_definition.
    add_to_output( VALUE #( layer    = get_formatted_layer( TEXT-010 )
                            object   = link->get_hmtl_link_for_object(
                                object_type = link->supported_objects-service_definition
                                object      = object-service_definition )
                            behavior = ''
                            metadata = '' ) ).
  ENDMETHOD.


  METHOD add_hierarchy.
    FIELD-SYMBOLS <layer> TYPE zif_mia_rap_analyzer=>rap_layer.

    ASSIGN COMPONENT node OF STRUCTURE object TO <layer>.

    DATA(rap_hierarchy_objects) = build_hierarchy_index_table( field = `CDS_ENTITY`
                                                               layer = <layer> ).

    DATA(rap_hierarchy_metadata) = build_hierarchy_index_table( field = `METADATA`
                                                                layer = <layer> ).

    add_to_output( VALUE #( layer    = get_formatted_layer( text )
                            object   = build_rap_hierarchy( hierarchies = rap_hierarchy_objects
                                                            object_type = zif_mia_object_link=>supported_objects-cds )
                            behavior = link->get_hmtl_link_for_object( object_type = link->supported_objects-behavior
                                                                       object      = <layer>-behavior )
                            metadata = build_rap_hierarchy(
                                hierarchies = rap_hierarchy_metadata
                                object_type = zif_mia_object_link=>supported_objects-metadata ) ) ).
  ENDMETHOD.


  METHOD add_table.
    DATA(rap_hierarchy_objects) = build_hierarchy_index_table( field = `TABLE`
                                                               layer = object-base ).

    add_to_output( VALUE #( layer    = get_formatted_layer( TEXT-011 )
                            object   = build_rap_hierarchy(
                                hierarchies = rap_hierarchy_objects
                                object_type = zif_mia_object_link=>supported_objects-database_table )
                            behavior = ''
                            metadata = '' ) ).
  ENDMETHOD.


  METHOD add_domains.
    DATA(domains) = ``.
    LOOP AT object-domains INTO DATA(domain).
      IF domains IS NOT INITIAL.
        domains &&= `<br>`.
      ENDIF.

      domains &&= link->get_hmtl_link_for_object( object_type = link->supported_objects-domain
                                                  object      = domain ).
    ENDLOOP.

    add_to_output( VALUE #( layer    = get_formatted_layer( TEXT-012 )
                            object   = domains
                            behavior = ''
                            metadata = '' ) ).
  ENDMETHOD.


  METHOD get_formatted_layer.
    RETURN '<strong>' && text && '</strong>'.
  ENDMETHOD.


  METHOD add_to_output.
    IF output-object IS INITIAL AND output-metadata IS INITIAL AND output-behavior IS INITIAL.
      RETURN.
    ENDIF.

    INSERT output INTO TABLE outputs.
  ENDMETHOD.


  METHOD add_package.
    add_to_output( VALUE #(
                       layer    = get_formatted_layer( text-013 )
                       object   = link->get_hmtl_link_for_object( object_type = link->supported_objects-package
                                                                  object      = object-package )
                       behavior = ''
                       metadata = '' ) ).
  ENDMETHOD.
ENDCLASS.
