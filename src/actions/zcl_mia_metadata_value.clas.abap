CLASS zcl_mia_metadata_value DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sd_value_help_dsni.

  PRIVATE SECTION.
    TYPES items TYPE STANDARD TABLE OF if_sd_value_help_dsni=>ty_named_item WITH EMPTY KEY.

    "! Get all fields for the Core Data Service
    "! @parameter core_data_service | Name of the CDS view
    "! @parameter result            | Items for Value Help
    METHODS get_fields
      IMPORTING core_data_service TYPE string
      RETURNING VALUE(result)     TYPE items.
ENDCLASS.


CLASS zcl_mia_metadata_value IMPLEMENTATION.
  METHOD if_sd_value_help_dsni~get_value_help_items.
    DATA input TYPE zcl_mia_metadata_input=>input.

    model->get_as_structure( IMPORTING result = input ).

    DATA(items) = get_fields( input-core_data_service ).

    result = VALUE #( items            = items
                      total_item_count = lines( items ) ).
  ENDMETHOD.


  METHOD get_fields.
    DATA(cds) = xco_cp_cds=>view_entity( CONV #( core_data_service ) ).
    IF NOT cds->exists( ).
      RETURN.
    ENDIF.

    LOOP AT cds->fields->all->get( ) INTO DATA(field).
      INSERT VALUE #( ) INTO TABLE result REFERENCE INTO DATA(actual).
      DATA(content) = field->content( )->get( ).

      IF content-alias IS NOT INITIAL.
        actual->name = content-alias.
      ELSEIF content-original_name IS NOT INITIAL.
        actual->name = content-original_name.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
