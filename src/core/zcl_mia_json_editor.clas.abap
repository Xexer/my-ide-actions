CLASS zcl_mia_json_editor DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_mia_json_editor.

  PRIVATE SECTION.
    CONSTANTS: BEGIN OF signs,
                 template TYPE string VALUE `|`,
                 string   TYPE string VALUE ``,
                 char     TYPE string VALUE `'`,
               END OF signs.

    METHODS normalize_string
      IMPORTING !line         TYPE string
      RETURNING VALUE(result) TYPE string.
ENDCLASS.


CLASS zcl_mia_json_editor IMPLEMENTATION.
  METHOD zif_mia_json_editor~extract_json_from_code.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(sources) = resource->get_source_code( ).
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(position) = resource->get_position( ).

    result = VALUE #( variable_name = 'new_json'
                      json_string   = |\{\n\n\}|
                      formatter     = zcl_mia_json_editor_input=>formatter-snake_lower ).
  ENDMETHOD.


  METHOD zif_mia_json_editor~format_json_string.
    DATA pretty_formatter TYPE /ui2/cl_json=>pretty_name_mode.

    DATA(json_object) = /ui2/cl_json=>generate( json        = input-json_string
                                                pretty_name = /ui2/cl_json=>pretty_mode-extended ).

    CASE input-formatter.
      WHEN zcl_mia_json_editor_input=>formatter-camel_case.
        pretty_formatter = /ui2/cl_json=>pretty_mode-camel_case.
      WHEN zcl_mia_json_editor_input=>formatter-pascal_case.
        pretty_formatter = /ui2/cl_json=>pretty_mode-pascal_case.
      WHEN zcl_mia_json_editor_input=>formatter-snake_lower.
        pretty_formatter = /ui2/cl_json=>pretty_mode-low_case.
      WHEN OTHERS.
        pretty_formatter = /ui2/cl_json=>pretty_mode-none.
    ENDCASE.

    DATA(local_json_result) = /ui2/cl_json=>serialize( data          = json_object
                                                       pretty_name   = pretty_formatter
                                                       format_output = abap_true ).

    result = local_json_result.
  ENDMETHOD.


  METHOD zif_mia_json_editor~convert_json_to_code.
    result = |DATA({ configuration-variable_name }) = `|.

    DATA(json_lines) = xco_cp=>string( configuration-json_string )->split( |\n| )->value.

    LOOP AT json_lines INTO DATA(line).
      line = normalize_string( line ).
      IF line IS INITIAL.
        CONTINUE.
      ENDIF.

      result &&= |{ line }` &&\n  `|.
    ENDLOOP.

    result &&= |`.|.
  ENDMETHOD.


  METHOD normalize_string.
    result = line.

    result = replace( val  = result
                      sub  = |\n|
                      with = ''  ).
    result = replace( val  = result
                      sub  = |\r|
                      with = ''  ).
    result = replace( val  = result
                      sub  = |`|
                      with = |\\`|  ).

    result = condense( result ).
  ENDMETHOD.
ENDCLASS.
