CLASS zcl_mia_strings DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS not_found TYPE i VALUE -1.

    TYPES: BEGIN OF extraction_result,
             found     TYPE abap_boolean,
             start     TYPE if_adt_context_source_position=>ts_cursor_position,
             end       TYPE if_adt_context_source_position=>ts_cursor_position,
             statement TYPE string,
           END OF extraction_result.

    "! Extract Namespace frpm package
    "! @parameter package | Name o the package
    "! @parameter result  | Prefix
    CLASS-METHODS get_prefix_from_package
      IMPORTING !package      TYPE sxco_package
      RETURNING VALUE(result) TYPE zif_mia_object_generator=>prefix.

    "! Extract the statement from the source code
    "! @parameter statement | ABAP statement
    "! @parameter sources   | Source Code
    "! @parameter start     | Start Position
    "! @parameter result    | Result of the extraction
    CLASS-METHODS extract_statement
      IMPORTING !statement    TYPE string
                sources       TYPE string_table
                !start        TYPE if_adt_context_source_position=>ts_cursor_position
      RETURNING VALUE(result) TYPE extraction_result.
ENDCLASS.


CLASS zcl_mia_strings IMPLEMENTATION.
  METHOD get_prefix_from_package.
    result = substring( val = package
                        len = 1 ).

    IF result <> '/'.
      RETURN result.
    ENDIF.

    DATA(position) = find( val = package
                           sub = '/'
                           off = 1 ).
    IF position = -1.
      RETURN 'Z'.
    ENDIF.

    RETURN substring( val = package
                      len = position + 1 ).
  ENDMETHOD.


  METHOD extract_statement.
    LOOP AT sources INTO DATA(source) FROM start-line TO 1 STEP -1.
      result-start-line   = sy-tabix.
      result-start-offset = find( val  = source
                                  sub  = `SELECT`
                                  case = abap_false ).
      IF result-start-offset <> not_found.
        EXIT.
      ENDIF.
    ENDLOOP.

    LOOP AT sources INTO source FROM start-line.
      result-end-line   = sy-tabix.
      result-end-offset = find( val  = source
                                sub  = `.`
                                case = abap_false ).
      IF result-end-offset <> not_found.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF result-start-offset = not_found OR result-end-offset = not_found.
      RETURN.
    ENDIF.

    result-end-offset += 1.

    LOOP AT sources INTO source FROM result-start-line TO result-end-line.
      CASE sy-tabix.
        WHEN result-start-line.
          result-statement &&= substring( val = source
                                          off = result-start-offset ).
        WHEN result-end-line.
          result-statement &&= substring( val = source
                                          len = result-end-offset ).
        WHEN OTHERS.
          result-statement &&= source.
      ENDCASE.
    ENDLOOP.

    result-found = xsdbool( result-statement IS NOT INITIAL ).
  ENDMETHOD.
ENDCLASS.
