INTERFACE zif_mia_html_rap
  PUBLIC.

  TYPES: BEGIN OF rap_output,
           layer    TYPE string,
           object   TYPE string,
           behavior TYPE string,
           metadata TYPE string,
         END OF rap_output.
  TYPES rap_outputs TYPE STANDARD TABLE OF rap_output WITH EMPTY KEY.

  TYPES: BEGIN OF rap_hierarchy,
           level  TYPE i,
           object TYPE string,
         END OF rap_hierarchy.
  TYPES rap_hierarchies TYPE STANDARD TABLE OF rap_hierarchy WITH EMPTY KEY.

  TYPES: BEGIN OF generation_result,
           output  TYPE rap_outputs,
           pattern TYPE string,
         END OF generation_result.

  CONSTANTS depth_level_sign TYPE string VALUE '➥'.

  "! Generate Output Table for RAP Object
  "! @parameter object | RAP Object from Analyzer
  "! @parameter result | Result from the Generation
  METHODS generate_rap_object_table
    IMPORTING !object       TYPE zif_mia_rap_analyzer=>rap_object
    RETURNING VALUE(result) TYPE generation_result.
ENDINTERFACE.
