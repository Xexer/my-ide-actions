CLASS zcl_mia_extension DEFINITION
  PUBLIC ABSTRACT.

  PUBLIC SECTION.
    INTERFACES zif_mia_extension_scenario.

    METHODS constructor
      IMPORTING !object TYPE zif_mia_rap_analyzer=>rap_object.

  PROTECTED SECTION.
    TYPES: BEGIN OF extracted_entity,
             interface   TYPE zif_mia_rap_analyzer=>rap_layer,
             consumption TYPE zif_mia_rap_analyzer=>rap_layer,
           END OF extracted_entity.

    DATA object          TYPE zif_mia_rap_analyzer=>rap_object.
    DATA link            TYPE REF TO zif_mia_object_link.
    DATA collected_steps TYPE zif_mia_extension_scenario=>steps.

    METHODS collect_step
      IMPORTING !option      TYPE string DEFAULT ``
                !description TYPE string
                !code        TYPE string DEFAULT ``
                !number      TYPE string DEFAULT ``.

    METHODS finalize_output_table
      RETURNING VALUE(result) TYPE zif_mia_extension_scenario=>steps.

    METHODS extract_layer_for_entity
      IMPORTING !entity       TYPE string
      RETURNING VALUE(result) TYPE extracted_entity.

    METHODS convert_db_field_to_cds
      IMPORTING !field        TYPE string
      RETURNING VALUE(result) TYPE string.

  PRIVATE SECTION.

ENDCLASS.


CLASS zcl_mia_extension IMPLEMENTATION.
  METHOD constructor.
    me->object = object.
    link = zcl_mia_core_factory=>create_object_link( ).
  ENDMETHOD.


  METHOD zif_mia_extension_scenario~generate_steps_for_new_field.
    " Redefine for implementation
  ENDMETHOD.


  METHOD collect_step.
    INSERT VALUE #( option      = option
                    description = description
                    code        = code
                    number      = number )
           INTO TABLE collected_steps.
  ENDMETHOD.


  METHOD finalize_output_table.
    result = collected_steps.
    DATA(step_number) = 1.
    DATA(sub_step) = abap_false.

    LOOP AT result REFERENCE INTO DATA(step).
      IF step->number IS NOT INITIAL.
        step->number = step_number && step->number.
        sub_step = abap_true.
      ELSE.
        IF sub_step = abap_true.
          sub_step = abap_false.
          step_number += 1.
        ENDIF.

        step->number = step_number.
        step_number += 1.
      ENDIF.

      step->status = |<input type="checkbox"></input>|.

      IF step->code IS NOT INITIAL.
        step->code = |<code>{ step->code }</code>|.
      ENDIF.
    ENDLOOP.

    INSERT VALUE #( number      = 'Number'
                    option      = 'Option'
                    description = 'Description'
                    code        = 'Code Example'
                    status      = 'Status' )
           INTO result INDEX 1.
  ENDMETHOD.


  METHOD extract_layer_for_entity.
    IF entity IS INITIAL.
      RETURN.
    ENDIF.

    IF object-base-cds_entity = entity.
      result-interface   = object-base.
      result-consumption = object-consumption.
    ELSE.
      LOOP AT object-base-childs INTO DATA(child) WHERE cds_entity = entity.
        result-interface = CORRESPONDING #( child ).
        result-interface-behavior = object-base-behavior.
        result-interface-metadata = object-base-metadata.
      ENDLOOP.

      LOOP AT object-consumption-childs INTO child.
        DATA(cds) = xco_cp_cds=>view_entity( CONV #( child-cds_entity ) ).
        DATA(child_entity) = cds->content( )->get_data_source( )-view_entity.

        IF result-interface-cds_entity <> to_upper( child_entity ).
          CONTINUE.
        ENDIF.

        result-consumption = CORRESPONDING #( child ).
        result-consumption-behavior = object-consumption-behavior.
        result-consumption-metadata = child-metadata.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD convert_db_field_to_cds.
    RETURN xco_cp=>string( field )->to_lower_case( )->split( '_' )->compose( xco_cp_string=>composition->pascal_case )->value.
  ENDMETHOD.
ENDCLASS.
