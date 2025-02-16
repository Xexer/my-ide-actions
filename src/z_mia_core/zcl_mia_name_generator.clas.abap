CLASS zcl_mia_name_generator DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_mia_name_generator.

  PRIVATE SECTION.
    CONSTANTS object_length TYPE i VALUE 30.

    "! Get main part for the object
    "! @parameter setting | Settings
    "! @parameter object  | Type of object (CL = Class, IF = Interface)
    "! @parameter result  | First part of the name
    METHODS get_main_part
      IMPORTING setting       TYPE zif_mia_object_generator=>setting
                !object       TYPE zif_mia_name_generator=>object_prefix
      RETURNING VALUE(result) TYPE sxco_ao_object_name.
ENDCLASS.


CLASS zcl_mia_name_generator IMPLEMENTATION.
  METHOD zif_mia_name_generator~generate_class_name.
    result = get_main_part( setting = setting
                            object  = 'CL' ).

    IF strlen( result ) > object_length.
      RAISE EXCEPTION NEW zcx_mia_error( ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_mia_name_generator~generate_factory_name.
    result = get_main_part( setting = setting
                            object  = 'CL' ).

    DATA(rest) = object_length - strlen( result ).

    IF rest >= 8.
      result &&= '_FACTORY'.
    ELSEIF rest >= 5.
      result &&= '_FACT'.
    ELSEIF rest >= 4.
      result &&= '_FCT'.
    ELSEIF rest >= 2.
      result &&= '_F'.
    ELSE.
      RAISE EXCEPTION NEW zcx_mia_error( ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_mia_name_generator~generate_injector_name.
    result = get_main_part( setting = setting
                            object  = 'CL' ).

    DATA(rest) = object_length - strlen( result ).

    IF rest >= 9.
      result &&= '_INJECTOR'.
    ELSEIF rest >= 7.
      result &&= '_INJECT'.
    ELSEIF rest >= 4.
      result &&= '_INJ'.
    ELSEIF rest >= 2.
      result &&= '_I'.
    ELSE.
      RAISE EXCEPTION NEW zcx_mia_error( ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_mia_name_generator~generate_interface_name.
    result = get_main_part( setting = setting
                            object  = 'IF' ).

    IF strlen( result ) > object_length.
      RAISE EXCEPTION NEW zcx_mia_error( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_main_part.
    RETURN |{ setting-prefix }{ object }_{ setting-name }|.
  ENDMETHOD.
ENDCLASS.
