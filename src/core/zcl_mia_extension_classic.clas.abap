CLASS zcl_mia_extension_classic DEFINITION
  PUBLIC
  INHERITING FROM zcl_mia_extension FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING !object TYPE zif_mia_rap_analyzer=>rap_object.

    METHODS
      zif_mia_extension_scenario~generate_steps_for_new_field REDEFINITION.

  PROTECTED SECTION.

  PRIVATE SECTION.
    "! Add step for database
    "! @parameter layer | RAP Layer
    "! @parameter field | Field
    METHODS add_step_database
      IMPORTING layer  TYPE zif_mia_rap_analyzer=>rap_layer
                !field TYPE string.

    "! Add step for interface layer
    "! @parameter layer | RAP Layer
    "! @parameter field | Field
    METHODS add_step_interface
      IMPORTING layer  TYPE zif_mia_rap_analyzer=>rap_layer
                !field TYPE string.

    "! Add step for consumption layer
    "! @parameter layer | RAP Layer
    "! @parameter field | Field
    METHODS add_step_consumption
      IMPORTING layer  TYPE zif_mia_rap_analyzer=>rap_layer
                !field TYPE string.

    "! Add step for Metadata Extension
    "! @parameter layer | RAP Layer
    "! @parameter field | Field
    "! @parameter root  | X = Root entity, '' = Other entity
    METHODS add_step_metadata
      IMPORTING layer  TYPE zif_mia_rap_analyzer=>rap_layer
                !field TYPE string
                !root  TYPE abap_boolean.

    "! Add step for Behavior definition
    "! @parameter layer | RAP Layer
    "! @parameter field | Field
    METHODS add_step_behavior
      IMPORTING layer  TYPE zif_mia_rap_analyzer=>rap_layer
                !field TYPE string.

    "! Add step for draft table
    "! @parameter layer | RAP Layer
    METHODS add_step_draft
      IMPORTING layer TYPE zif_mia_rap_analyzer=>rap_layer.

    "! Add step for activation
    METHODS add_step_activate.
ENDCLASS.


CLASS zcl_mia_extension_classic IMPLEMENTATION.
  METHOD constructor.
    super->constructor( object ).
  ENDMETHOD.


  METHOD zif_mia_extension_scenario~generate_steps_for_new_field.
    CLEAR collected_steps.
    DATA(enhanced_entity) = extract_layer_for_entity( new_field-entity ).

    add_step_database( layer = enhanced_entity-interface
                       field = new_field-name ).
    add_step_interface( layer = enhanced_entity-interface
                        field = new_field-name ).
    add_step_consumption( layer = enhanced_entity-consumption
                          field = new_field-name ).
    add_step_activate( ).
    add_step_behavior( layer = enhanced_entity-interface
                       field = new_field-name ).
    add_step_draft( enhanced_entity-interface ).
    add_step_metadata( layer = enhanced_entity-consumption
                       field = new_field-name
                       root  = enhanced_entity-root ).
    add_step_activate( ).

    RETURN finalize_output_table( ).
  ENDMETHOD.


  METHOD add_step_database.
    DATA(db_field) = to_lower( field ).
    DATA(link_ref) = link->get_hmtl_link_for_object( object_type = link->supported_objects-database_table
                                                     object      = layer-table ).

    collect_step(
        description = |Add field <strong>{ db_field }</strong> to table { link_ref } and adjust type to your needs.|
        code        = |{ db_field } : abap.char(15);| ).
  ENDMETHOD.


  METHOD add_step_interface.
    DATA(db_field) = to_lower( field ).
    DATA(cds_field) = convert_db_field_to_cds( field ).
    DATA(link_ref) = link->get_hmtl_link_for_object( object_type = link->supported_objects-cds
                                                     object      = layer-cds_entity ).

    collect_step(
        description = |Add field <strong>{ db_field }</strong> with mapping to Core Data Service { link_ref }.|
        code        = |{ db_field } as { cds_field },| ).
  ENDMETHOD.


  METHOD add_step_consumption.
    DATA(cds_field) = convert_db_field_to_cds( field ).
    DATA(link_ref) = link->get_hmtl_link_for_object( object_type = link->supported_objects-cds
                                                     object      = layer-cds_entity ).

    collect_step( description = |Add field <strong>{ cds_field }</strong> to Core Data Service { link_ref }.|
                  code        = |{ cds_field },| ).
  ENDMETHOD.


  METHOD add_step_behavior.
    DATA(db_field) = to_lower( field ).
    DATA(cds_field) = convert_db_field_to_cds( field ).
    DATA(link_ref) = link->get_hmtl_link_for_object( object_type = link->supported_objects-behavior
                                                     object      = layer-behavior ).

    collect_step( description = |Add mapping for <strong>{ db_field }</strong> to Behavior Definition { link_ref }.|
                  code        = |{ cds_field } = { db_field };| ).
  ENDMETHOD.


  METHOD add_step_metadata.
    DATA(cds_field) = convert_db_field_to_cds( field ).
    DATA(link_ref) = link->get_hmtl_link_for_object( object_type = link->supported_objects-metadata
                                                     object      = layer-metadata ).

    collect_step(
        number      = `a`
        option      = zif_mia_extension_scenario=>options-choose
        description = |Add field <strong>{ cds_field }</strong> to Metadata Extension { link_ref } as LineItem.|
        code        = |@UI.lineItem: [ \{ position: 10, qualifier: '' \} ]<br>{ cds_field };| ).

    collect_step(
        number      = `b`
        option      = zif_mia_extension_scenario=>options-choose
        description = |Add field <strong>{ cds_field }</strong> to Metadata Extension { link_ref } as Identification.|
        code        = |@UI.identification: [ \{ position: 10, qualifier: '' \} ]<br>{ cds_field };| ).

    collect_step(
        number      = `c`
        option      = zif_mia_extension_scenario=>options-choose
        description = |Add field <strong>{ cds_field }</strong> to Metadata Extension { link_ref } as FieldGroup.|
        code        = |@UI.fieldGroup: [ \{ position: 10, qualifier: '' \} ]<br>{ cds_field };| ).

    IF root = abap_true.
      collect_step(
          number      = `d`
          option      = zif_mia_extension_scenario=>options-choose
          description = |Add field <strong>{ cds_field }</strong> to Metadata Extension { link_ref } as SelectionField.|
          code        = |@UI.selectionField: [ \{ position: 10 \} ]<br>{ cds_field };| ).

    ENDIF.
  ENDMETHOD.


  METHOD add_step_draft.
    DATA(link_ref) = link->get_hmtl_link_for_object( object_type = link->supported_objects-behavior
                                                     object      = layer-behavior ).

    collect_step(
        option      = zif_mia_extension_scenario=>options-optional
        description = |Recreate draft table in Behavior Definition { link_ref }. You can use Quick Fix via CTRL + 1.| ).
  ENDMETHOD.


  METHOD add_step_activate.
    collect_step( description = |Mass activate all objects.| ).
  ENDMETHOD.
ENDCLASS.
