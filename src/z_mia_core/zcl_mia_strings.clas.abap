CLASS zcl_mia_strings DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    "! Extract Namespace frpm package
    "! @parameter package | Name o the package
    "! @parameter result  | Prefix
    CLASS-METHODS get_prefix_from_package
      IMPORTING !package      TYPE sxco_package
      RETURNING VALUE(result) TYPE zif_mia_object_generator=>prefix.
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
ENDCLASS.
