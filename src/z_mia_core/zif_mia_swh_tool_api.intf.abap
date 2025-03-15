INTERFACE zif_mia_swh_tool_api
  PUBLIC.

  TYPES: BEGIN OF convert_data,
           new_statement TYPE string,
           errors        TYPE string_table,
         END OF convert_data.

  TYPES: BEGIN OF convert_answer,
           success    TYPE abap_bool,
           error_code TYPE string,
           http_code  TYPE i,
           data       TYPE convert_data,
         END OF convert_answer.

  TYPES: BEGIN OF convert_request,
           statement  TYPE string,
           abap_cloud TYPE string,
         END OF convert_request.

  "! Convert SELECT statement to the new version with CDS views
  "! @parameter request | Request data
  "! @parameter result  | Result set
  METHODS convert_select_statement
    IMPORTING !request      TYPE convert_request
    RETURNING VALUE(result) TYPE convert_answer.
ENDINTERFACE.
