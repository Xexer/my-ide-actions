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
ENDINTERFACE.
