CLASS zcl_mia_consumption_action DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_action.

  PRIVATE SECTION.
    METHODS prepare_field_mapping
      IMPORTING !input        TYPE zcl_mia_consumption_input=>input
      RETURNING VALUE(result) TYPE string.
ENDCLASS.


CLASS zcl_mia_consumption_action IMPLEMENTATION.
  METHOD if_aia_action~run.
    DATA input TYPE zcl_mia_consumption_input=>input.

    TRY.
        context->get_input_config_content( )->get_as_structure( IMPORTING result = input ).

      CATCH cx_sd_invalid_data.
        CLEAR input.
    ENDTRY.

    DATA(resource) = CAST if_adt_context_src_based_obj( context->get_focused_resource( ) ).
    DATA(position) = resource->get_position( ).

    DATA(mapped_fields) = prepare_field_mapping( input ).

    DATA(change_result) = cl_aia_result_factory=>create_source_change_result( ).
    change_result->add_code_replacement_delta( content            = mapped_fields
                                               selection_position = position ).
    result = change_result.
  ENDMETHOD.


  METHOD prepare_field_mapping.
    DATA(analyzer) = zcl_mia_core_factory=>create_class_analyzer( CONV #( input-class ) ).

    LOOP AT analyzer->get_structure_for_type( input-structure ) INTO DATA(definition).
      DATA(key_field) = ``.
      IF definition-key = abap_true.
        key_field = `key `.
      ENDIF.

      IF definition-label IS NOT INITIAL.
        result &&= |\n @EndUserText.label: '{ definition-label }'|.
      ENDIF.

      result &&= |\n { key_field }{ definition-name } : { definition-type };|.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
