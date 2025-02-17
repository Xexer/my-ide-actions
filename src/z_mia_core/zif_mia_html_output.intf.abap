INTERFACE zif_mia_html_output
  PUBLIC.

  TYPES: BEGIN OF generated_object,
           object_type TYPE string,
           name        TYPE string,
         END OF generated_object.

  TYPES generated_objects TYPE STANDARD TABLE OF generated_object WITH EMPTY KEY.

  TYPES: BEGIN OF generated_error,
           object_name TYPE string,
           message     TYPE string,
         END OF generated_error.

  TYPES generated_errors TYPE STANDARD TABLE OF generated_error WITH EMPTY KEY.

  "! Generate from the result
  "! @parameter generation_result | Result of the generation
  "! @parameter result            | HTML output for console
  METHODS generate_html_output
    IMPORTING generation_result TYPE zif_mia_object_generator=>generation_result
    RETURNING VALUE(result)     TYPE string.
ENDINTERFACE.
