INTERFACE zif_mia_metadata
  PUBLIC.

  TYPES metadata_input TYPE zcl_mia_metadata_input=>input.
  TYPES facet          TYPE zcl_mia_metadata_input=>facet.
  TYPES field          TYPE zcl_mia_metadata_input=>field.

  "! Generate the Metadata Extension Code
  "! @parameter input  | Input for Generation
  "! @parameter result | New Code
  METHODS generate_metadata_code
    IMPORTING !input        TYPE metadata_input
    RETURNING VALUE(result) TYPE string.

  "! Parse the source code for the input structure
  "! @parameter core_data_service | CDS View name
  "! @parameter code              | Source Code of Metadata
  "! @parameter result            | Input for Action
  METHODS parse_source_code_to_input
    IMPORTING core_data_service TYPE string
              !code             TYPE string_table
    RETURNING VALUE(result)     TYPE metadata_input.
ENDINTERFACE.
