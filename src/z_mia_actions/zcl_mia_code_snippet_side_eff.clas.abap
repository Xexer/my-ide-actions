CLASS zcl_mia_code_snippet_side_eff DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sd_determination.
    INTERFACES if_sd_feature_control.
ENDCLASS.


CLASS zcl_mia_code_snippet_side_eff IMPLEMENTATION.
  METHOD if_sd_determination~run.
    DATA input TYPE zcl_mia_code_snippet_input=>input.

    IF determination_kind <> if_sd_determination=>kind-after_update.
      RETURN.
    ENDIF.

    model->get_as_structure( IMPORTING result = input ).

    IF input-type <> zcl_mia_code_snippet_action=>supported_types-behavior.

    ENDIF.

    result = input.
  ENDMETHOD.


  METHOD if_sd_feature_control~run.
    DATA input TYPE zcl_mia_code_snippet_input=>input.

    model->get_as_structure( IMPORTING result = input ).
    DATA(feature_control) = feature_control_factory->create_for_data( input ).

    IF input-type <> zcl_mia_code_snippet_action=>supported_types-behavior.
      feature_control->get_element( 'ENTITY' )->set_hidden( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
