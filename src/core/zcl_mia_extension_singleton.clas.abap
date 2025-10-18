CLASS zcl_mia_extension_singleton DEFINITION
  PUBLIC
  INHERITING FROM zcl_mia_extension FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING !object TYPE zif_mia_rap_analyzer=>rap_object.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_mia_extension_singleton IMPLEMENTATION.
  METHOD constructor.
    super->constructor( object ).
  ENDMETHOD.
ENDCLASS.
