CLASS zcl_mia_code_snippet_side_eff DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sd_determination.
    INTERFACES if_sd_feature_control.
ENDCLASS.


CLASS zcl_mia_code_snippet_side_eff IMPLEMENTATION.
  METHOD if_sd_determination~run.
  ENDMETHOD.


  METHOD if_sd_feature_control~run.
    DATA input   TYPE zcl_mia_code_snippet_input=>input.
    DATA setting TYPE zcl_mia_code_snippet_input=>setting_field.

    model->get_as_structure( IMPORTING result = input ).
    DATA(feature_control) = feature_control_factory->create_for_data( input ).

    CASE input-type.
      WHEN zcl_mia_code_snippet_action=>supported_types-cds.
        CASE input-template_cds.
          WHEN zcl_mia_code_snippet_input=>template_value_cds-cds_vh_define.
            setting-entity = abap_true.
            setting-field  = abap_true.

          WHEN zcl_mia_code_snippet_input=>template_value_cds-cds_vh_data_element.
            setting-data_element = abap_true.
            setting-field        = abap_true.

        ENDCASE.

    ENDCASE.

    IF setting-entity IS INITIAL.
      feature_control->get_element( `entity` )->set_hidden( ).
    ENDIF.

    IF setting-field IS INITIAL.
      feature_control->get_element( `field` )->set_hidden( ).
    ENDIF.

    IF setting-data_element IS INITIAL.
      feature_control->get_element( `data_element` )->set_hidden( ).
    ENDIF.

    RETURN feature_control.
  ENDMETHOD.
ENDCLASS.
