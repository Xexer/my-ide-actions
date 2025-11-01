CLASS zcl_mia_json_editor_input DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_sd_action_input.

    CONSTANTS refresh_text TYPE string VALUE `Change to refresh`.

    CONSTANTS:
      BEGIN OF formatter,
        "! <p class="shorttext">camelCase</p>
        camel_case  TYPE string VALUE `camelCase`,
        "! <p class="shorttext">PascalCase</p>
        pascal_case TYPE string VALUE `PascalCase`,
        "! <p class="shorttext">snake_lower</p>
        snake_lower TYPE string VALUE `snake_lower`,
        "! <p class="shorttext">SNAKE_UPPER</p>
        snake_upper TYPE string VALUE `SNAKE_UPPER`,
      END OF formatter.

    "! $values { @link zcl_mia_json_editor_input.data:formatter }
    "! $default { @link zcl_mia_json_editor_input.data:formatter.camel_case }
    TYPES json_formatter TYPE string.

    TYPES:
      "! <p class="shorttext">Edit JSON</p>
      BEGIN OF input,
        "! <p class="shorttext">Name of variable</p>
        variable_name TYPE string,
        "! <p class="shorttext">Output format</p>
        formatter     TYPE json_formatter,
        "! <p class="shorttext">JSON</p>
        json_string   TYPE string,
        "! <p class="shorttext">Refresh</p>
        refresh       TYPE string,
      END OF input.
ENDCLASS.


CLASS zcl_mia_json_editor_input IMPLEMENTATION.
  METHOD if_aia_sd_action_input~create_input_config.
    DATA input TYPE input.

    IF context IS BOUND.
      DATA(resource) = CAST if_adt_context_src_based_obj( context->get_focused_resource( ) ).

      DATA(json_editor) = zcl_mia_core_factory=>create_json_editor( ).
      DATA(extracted_json) = json_editor->extract_json_from_code( resource ).

      input-variable_name = extracted_json-variable_name.
      input-json_string   = extracted_json-json_string.
      input-formatter     = extracted_json-formatter.
      input-refresh       = refresh_text.
    ENDIF.

    DATA(configuration) = ui_information_factory->get_configuration_factory( )->create_for_data( input ).

    configuration->get_element( `json_string` )->set_multiline( if_sd_config_element=>height-large ).
    configuration->get_element( `refresh` )->set_sideeffect( after_update = abap_true ).

    RETURN ui_information_factory->for_abap_type( abap_type     = input
                                                  configuration = configuration ).
  ENDMETHOD.


  METHOD if_aia_sd_action_input~get_side_effect_provider.
    RETURN cl_sd_sideeffect_provider=>create( determination = NEW zcl_mia_json_editor_side_eff( ) ).
  ENDMETHOD.
ENDCLASS.
