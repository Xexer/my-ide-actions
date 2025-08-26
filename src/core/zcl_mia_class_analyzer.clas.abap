CLASS zcl_mia_class_analyzer DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_mia_class_analyzer.

    METHODS constructor
      IMPORTING class_name TYPE zif_mia_class_analyzer=>class_name.

  PRIVATE SECTION.
    CONSTANTS:
      BEGIN OF simple_types,
        char   TYPE string VALUE `C`,
        packed TYPE string VALUE `P`,
        bool   TYPE string VALUE `ABAP_BOOL`,
        string TYPE string VALUE `STRING`,
      END OF simple_types.

    CONSTANTS:
      BEGIN OF modes,
        length   TYPE string VALUE `LENGTH`,
        decimals TYPE string VALUE `DECIMALS`,
      END OF modes.

    DATA class_name TYPE zif_mia_class_analyzer=>class_name.

    "! Convert the source code to fields and types
    "! @parameter source | Source code
    "! @parameter result | Table of field names and basic types
    METHODS convert_source
      IMPORTING !source       TYPE string
      RETURNING VALUE(result) TYPE zif_mia_class_analyzer=>structure_types.

    "! Get the type of a field
    "! @parameter type   | Part of the source code (after TYPE)
    "! @parameter result | Extracted basic type
    METHODS get_type
      IMPORTING !type         TYPE string
      RETURNING VALUE(result) TYPE string.
ENDCLASS.


CLASS zcl_mia_class_analyzer IMPLEMENTATION.
  METHOD constructor.
    me->class_name = class_name.
  ENDMETHOD.


  METHOD zif_mia_class_analyzer~is_consumption_model.
    DATA(class) = xco_cp_abap=>class( class_name ).

    RETURN xsdbool( class->definition->content( )->get_superclass( )->name = '/IWBEP/CL_V4_ABS_PM_MODEL_PROV' ).
  ENDMETHOD.


  METHOD zif_mia_class_analyzer~get_structure_for_type.
    DATA(class) = xco_cp_abap=>class( class_name ).
    DATA(all_types) = class->definition->section-public->components->type->all->get( ).

    LOOP AT all_types INTO DATA(local_type).
      IF local_type->name = type_name.
        DATA(source) = local_type->content( )->get_typing_definition( )->get_source( ).
        result = convert_source( source ).
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_mia_class_analyzer~get_types.
    DATA(class) = xco_cp_abap=>class( class_name ).
    DATA(all_types) = class->definition->section-public->components->type->all->get( ).

    LOOP AT all_types INTO DATA(local_type).
      DATA(source) = local_type->content( )->get_typing_definition( )->get_source( ).

      IF to_upper( source ) CS 'BEGIN OF'.
        INSERT VALUE #( name = local_type->name
                        type = local_type->content( )->get_short_description( ) ) INTO TABLE result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD convert_source.
    DATA(lines) = xco_cp=>string( source )->split( |\n| )->value.

    LOOP AT lines INTO DATA(line) WHERE table_line CS 'TYPE'.
      line = replace( val  = line
                      sub  = |\n|
                      with = ''  ).
      line = replace( val  = line
                      sub  = |\r|
                      with = ''  ).

      DATA(fields) = xco_cp=>string( line )->split( |TYPE| )->value.

      TRY.
          DATA(name) = fields[ 1 ].
          DATA(type) = fields[ 2 ].
        CATCH cx_sy_itab_line_not_found.
          CONTINUE.
      ENDTRY.

      name = replace( val  = name
                      sub  = ` `
                      with = ``
                      occ  = 0 ).
      type = get_type( type ).

      INSERT VALUE #( name = name
                      type = type )
             INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_type.
    DATA simple_type TYPE string.
    DATA length      TYPE string.
    DATA decimals    TYPE string.

    DATA(clean_type) = replace( val  = type
                                sub  = `,`
                                with = ``
                                occ  = 0 ).

    DATA(lines) = xco_cp=>string( clean_type )->split( ` ` )->value.

    LOOP AT lines INTO DATA(line) WHERE table_line IS NOT INITIAL.
      DATA(actual_line) = sy-tabix.
      IF simple_type IS INITIAL.
        simple_type = line.
        CONTINUE.
      ENDIF.

      CASE line.
        WHEN modes-length.
          length = lines[ actual_line + 1 ].
        WHEN modes-decimals.
          decimals = lines[ actual_line + 1 ].
      ENDCASE.
    ENDLOOP.

    CASE to_upper( simple_type ).
      WHEN simple_types-char.
        RETURN |abap.char({ length })|.

      WHEN simple_types-packed.
        RETURN |abap.dec({ length }, { decimals })|.

      WHEN simple_types-bool.
        RETURN `abap_boolean`.

      WHEN simple_types-string.
        RETURN `abap.string`.

      WHEN OTHERS.
        RETURN simple_type.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
