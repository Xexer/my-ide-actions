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

    "! Check if key property is assigned
    "! @parameter description | Description field
    "! @parameter result      | X = Key field, '' = normal field
    METHODS get_key_property
      IMPORTING !description  TYPE string
      RETURNING VALUE(result) TYPE abap_boolean.

    "! Extract label from line
    "! @parameter description | Description field
    "! @parameter result      | Only label
    METHODS get_label_property
      IMPORTING !description  TYPE string
      RETURNING VALUE(result) TYPE string.

    "! Check if the field is a special field
    "! @parameter description | Description field
    "! @parameter result      | X = Skip, '' = Don't skip
    METHODS skip_special_fields
      IMPORTING !description  TYPE string
      RETURNING VALUE(result) TYPE abap_bool.

    "! Remove special signs and spaces from text
    "! @parameter line   | Field
    "! @parameter result | Normalized text field
    METHODS normalize_line
      IMPORTING !line         TYPE string
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
      DATA(actual_line) = sy-tabix.
      line = normalize_line( line ).
      DATA(fields) = xco_cp=>string( line )->split( |TYPE| )->value.

      TRY.
          DATA(name) = fields[ 1 ].
          DATA(type) = fields[ 2 ].
        CATCH cx_sy_itab_line_not_found.
          CONTINUE.
      ENDTRY.

      TRY.
          DATA(description) = lines[ actual_line - 1 ].
          description = normalize_line( description ).
        CATCH cx_sy_itab_line_not_found.
          CLEAR description.
      ENDTRY.

      IF skip_special_fields( description ).
        CONTINUE.
      ENDIF.

      name = replace( val  = name
                      sub  = ` `
                      with = ``
                      occ  = 0 ).
      type = get_type( type ).

      INSERT VALUE #( name  = name
                      type  = type
                      key   = get_key_property( description )
                      label = get_label_property( description ) )
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


  METHOD get_key_property.
    IF to_upper( description ) CS `<EM>KEY PROPERTY</EM>`.
      RETURN abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD get_label_property.
    IF substring( val = description
                  len = 2 ) <> `"!`.
      RETURN ``.
    ENDIF.

    result = substring( val = description
                        off = 3 ).

    DATA(position) = find( val = result
                           sub = '>'
                           occ = -1 ).
    IF position = -1.
      RETURN.
    ENDIF.

    result = substring( val = result
                        off = position + 1 ).
    result = condense( result ).
  ENDMETHOD.


  METHOD skip_special_fields.
    IF    to_upper( description ) CS `<EM>VALUE CONTROL STRUCTURE</EM>`
       OR to_upper( description ) CS `ODATA.ETAG`.
      RETURN abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD normalize_line.
    result = line.

    result = replace( val  = result
                      sub  = |\n|
                      with = ''  ).
    result = replace( val  = result
                      sub  = |\r|
                      with = ''  ).

    result = condense( result ).
  ENDMETHOD.
ENDCLASS.
