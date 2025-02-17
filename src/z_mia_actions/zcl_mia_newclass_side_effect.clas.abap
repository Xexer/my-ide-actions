CLASS zcl_mia_newclass_side_effect DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sd_determination.

  PRIVATE SECTION.
    "! Get names for objects
    "! @parameter popup_data | Data from the popup
    METHODS determine_names
      CHANGING popup_data TYPE zcl_mia_newclass_input=>input.
ENDCLASS.


CLASS zcl_mia_newclass_side_effect IMPLEMENTATION.
  METHOD if_sd_determination~run.
    DATA popup_data TYPE zcl_mia_newclass_input=>input.

    IF determination_kind <> if_sd_determination=>kind-after_update.
      RETURN.
    ENDIF.

    model->get_as_structure( IMPORTING result = popup_data ).
    determine_names( CHANGING popup_data = popup_data ).
    result = popup_data.
  ENDMETHOD.


  METHOD determine_names.
    IF popup_data-prefix IS INITIAL OR popup_data-name IS INITIAL.
      RETURN.
    ENDIF.

    DATA(name) = zcl_mia_core_factory=>create_name_generator( ).

    TRY.
        popup_data-interface = name->generate_interface_name( CORRESPONDING #( popup_data ) ).
        popup_data-class     = name->generate_class_name( CORRESPONDING #( popup_data ) ).
        popup_data-factory   = name->generate_factory_name( CORRESPONDING #( popup_data ) ).
        popup_data-injector  = name->generate_injector_name( CORRESPONDING #( popup_data ) ).

      CATCH zcx_mia_error.
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
