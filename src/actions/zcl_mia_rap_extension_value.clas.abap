CLASS zcl_mia_rap_extension_value DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sd_value_help_dsni.
ENDCLASS.


CLASS zcl_mia_rap_extension_value IMPLEMENTATION.
  METHOD if_sd_value_help_dsni~get_value_help_items.
    DATA input TYPE zcl_mia_rap_extension_input=>input.

    TRY.
        model->get_as_structure( IMPORTING result = input ).
      CATCH cx_sd_invalid_data.
        CLEAR input.
    ENDTRY.

    DATA(analyzer) = zcl_mia_core_factory=>create_rap_analyzer(
        object_name = input-service_name
        object_type = zif_mia_rap_analyzer=>start_object-service_binding ).

    DATA(items) = analyzer->get_entities_for_service( input-service_name ).

    result = VALUE #( items            = items
                      total_item_count = lines( items ) ).
  ENDMETHOD.
ENDCLASS.
