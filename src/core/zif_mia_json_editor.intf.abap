INTERFACE zif_mia_json_editor
  PUBLIC.

  "! Extract JSON from actual selected Code
  "! @parameter resource | Selected resource
  "! @parameter result   | Extracted data
  METHODS extract_json_from_code
    IMPORTING resource      TYPE REF TO if_adt_context_src_based_obj
    RETURNING VALUE(result) TYPE zcl_mia_json_editor_input=>input.

  "! Reformat the JSON string for output
  "! @parameter input  | Configuration
  "! @parameter result | JSON output
  METHODS format_json_string
    IMPORTING !input        TYPE zcl_mia_json_editor_input=>input
    RETURNING VALUE(result) TYPE string.

  "! Convert the JSON to ABAP Code
  "! @parameter configuration | Field and JSON
  "! @parameter result        | Formatted ABAP Code
  METHODS convert_json_to_code
    IMPORTING configuration TYPE zcl_mia_json_editor_input=>input
    RETURNING VALUE(result) TYPE string.
ENDINTERFACE.
