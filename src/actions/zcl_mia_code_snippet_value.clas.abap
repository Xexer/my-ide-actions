CLASS zcl_mia_code_snippet_value DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sd_value_help_dsni.

  PRIVATE SECTION.
    TYPES items TYPE STANDARD TABLE OF if_sd_value_help_dsni=>ty_named_item WITH EMPTY KEY.

    METHODS get_fields_from_cds
      IMPORTING entity_name   TYPE string
      RETURNING VALUE(result) TYPE items.
ENDCLASS.


CLASS zcl_mia_code_snippet_value IMPLEMENTATION.
  METHOD if_sd_value_help_dsni~get_value_help_items.
    DATA input TYPE zcl_mia_code_snippet_input=>input.
    DATA items TYPE STANDARD TABLE OF if_sd_value_help_dsni=>ty_named_item.

    TRY.
        model->get_as_structure( IMPORTING result = input ).
      CATCH cx_sd_invalid_data.
        CLEAR input.
    ENDTRY.

    IF input-entity IS NOT INITIAL.
      items = get_fields_from_cds( input-entity ).
    ENDIF.

    result = VALUE #( items            = items
                      total_item_count = lines( items ) ).
  ENDMETHOD.


  METHOD get_fields_from_cds.
    DATA(cds) = xco_cp_cds=>view_entity( CONV #( entity_name ) ).
    IF NOT cds->exists( ).
      RETURN.
    ENDIF.

    LOOP AT cds->fields->all->get( ) INTO DATA(field).
      DATA(description) = CONV string( field->name ).
      IF field->content( )->get( )-key_indicator = abap_true.
        description &&= | { TEXT-001 }|.
      ENDIF.

      INSERT VALUE #( name        = field->content( )->get_original_name( )
                      description = description ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
