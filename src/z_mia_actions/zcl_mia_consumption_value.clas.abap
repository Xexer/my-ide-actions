CLASS zcl_mia_consumption_value DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sd_value_help_dsni.
ENDCLASS.


CLASS zcl_mia_consumption_value IMPLEMENTATION.
  METHOD if_sd_value_help_dsni~get_value_help_items.
    DATA input TYPE zcl_mia_consumption_input=>input.
    DATA items TYPE STANDARD TABLE OF if_sd_value_help_dsni=>ty_named_item.

    TRY.
        model->get_as_structure( IMPORTING result = input ).
      CATCH cx_sd_invalid_data.
        CLEAR input.
    ENDTRY.

    DATA(analyzer) = zcl_mia_core_factory=>create_class_analyzer( CONV #( input-class ) ).

    LOOP AT analyzer->get_types( ) INTO DATA(structure).
      INSERT VALUE #( name        = structure-name
                      description = structure-type ) INTO TABLE items.
    ENDLOOP.

    result = VALUE #( items            = items
                      total_item_count = lines( items ) ).
  ENDMETHOD.
ENDCLASS.
