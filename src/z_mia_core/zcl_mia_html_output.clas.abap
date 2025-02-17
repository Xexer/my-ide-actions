CLASS zcl_mia_html_output DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_mia_html_output.

  PRIVATE SECTION.
    DATA output TYPE string.

    "! Build HTML Header
    "! @parameter text | Text for Header
    METHODS generate_header
      IMPORTING !text TYPE string.

    "! Create HTML Breaks
    "! @parameter number | Number of breaks
    METHODS generate_break
      IMPORTING !number TYPE i DEFAULT 1.

    "! Build HTML Table from generic data
    "! @parameter generic_data | Data
    METHODS generate_table
      IMPORTING generic_data TYPE REF TO data.

    "! Create Result-Object table
    "! @parameter generation_result | Result from Run
    METHODS build_object_table
      IMPORTING generation_result TYPE zif_mia_object_generator=>generation_result.

    "! Create Error-Object table
    "! @parameter generation_result | Result from Run
    METHODS build_error_table
      IMPORTING generation_result TYPE zif_mia_object_generator=>generation_result.

    "! Finalize HTML Document
    "! @parameter result | HTML Document
    METHODS finalize_document
      RETURNING VALUE(result) TYPE string.

    "! Create Message-Object table
    "! @parameter generation_result | Result from Run
    METHODS build_message_table
      IMPORTING generation_result TYPE zif_mia_object_generator=>generation_result.
ENDCLASS.


CLASS zcl_mia_html_output IMPLEMENTATION.
  METHOD zif_mia_html_output~generate_html_output.
    CLEAR output.

    generate_header( |{ TEXT-001 } [{ generation_result-transport }]| ).
    build_message_table( generation_result ).
    build_error_table( generation_result ).
    build_object_table( generation_result ).

    RETURN finalize_document( ).
  ENDMETHOD.


  METHOD build_object_table.
    DATA(objects) = VALUE zif_mia_html_output=>generated_objects( ( object_type = TEXT-006 name = TEXT-007 ) ).

    IF generation_result-interface IS NOT INITIAL.
      INSERT VALUE #( object_type = TEXT-002
                      name        = generation_result-interface ) INTO TABLE objects.
    ENDIF.

    IF generation_result-class IS NOT INITIAL.
      INSERT VALUE #( object_type = TEXT-003
                      name        = generation_result-class ) INTO TABLE objects.
    ENDIF.

    IF generation_result-factory IS NOT INITIAL.
      INSERT VALUE #( object_type = TEXT-004
                      name        = generation_result-factory ) INTO TABLE objects.
    ENDIF.

    IF generation_result-injector IS NOT INITIAL.
      INSERT VALUE #( object_type = TEXT-005
                      name        = generation_result-injector ) INTO TABLE objects.
    ENDIF.

    generate_table( REF #( objects ) ).
  ENDMETHOD.


  METHOD generate_table.
    DATA table_result TYPE string.
    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>  TYPE any.

    ASSIGN generic_data->* TO <table>.
    DATA(header) = abap_true.

    IF lines( <table> ) > 1.
      generate_break( ).
    ELSE.
      RETURN.
    ENDIF.

    LOOP AT <table> ASSIGNING <line>.
      table_result &&= `<tr>`.

      DO.
        DATA(index) = sy-index.
        ASSIGN COMPONENT index OF STRUCTURE <line> TO FIELD-SYMBOL(<field>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        IF header = abap_true.
          table_result &&= |<th>{ <field> }</th>|.
        ELSE.
          table_result &&= |<td>{ <field> }</td>|.
        ENDIF.
      ENDDO.

      table_result &&= `</tr>`.
      header = abap_false.
    ENDLOOP.

    output &&= |<table>{ table_result }</table>|.
  ENDMETHOD.


  METHOD generate_header.
    output &&= |<h3>{ text }</h3>|.
  ENDMETHOD.


  METHOD build_error_table.
    IF generation_result-findings IS NOT BOUND.
      RETURN.
    ENDIF.

    DATA(errors) = VALUE zif_mia_html_output=>generated_errors( ( object_name = TEXT-007 message = TEXT-009 ) ).

    LOOP AT generation_result-findings->get( ) INTO DATA(message).
      INSERT VALUE #( object_name = message->object_name
                      message     = message->message->get_text( ) ) INTO TABLE errors.
    ENDLOOP.

    generate_table( REF #( errors ) ).
  ENDMETHOD.


  METHOD generate_break.
    DO number TIMES.
      output &&= |<br>|.
    ENDDO.
  ENDMETHOD.


  METHOD finalize_document.
    DATA(css) = `table { border-collapse: collapse; } `.
    css &&= `td, th { padding: 5px 12px; } `.
    css &&= |th \{ background-color: black; color: white; \} |.

    RETURN |<!DOCTYPE html lang="en">| &
           |<head>| &
           |  <style>| &
           |    { css }| &
           |  </style>| &
           |</head>| &
           |<body>| &
           |  { output }| &
           |</body>| &
           |</html>|.
  ENDMETHOD.


  METHOD build_message_table.
    DATA(errors) = VALUE zif_mia_html_output=>generated_errors( ( object_name = TEXT-007 message = TEXT-009 ) ).

    LOOP AT generation_result-messages INTO DATA(message).
      INSERT VALUE #( object_name = TEXT-010
                      message     = message->get_text( ) ) INTO TABLE errors.
    ENDLOOP.

    generate_table( REF #( errors ) ).
  ENDMETHOD.
ENDCLASS.
