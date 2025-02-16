CLASS zcl_mia_core_factory DEFINITION
  PUBLIC ABSTRACT FINAL.

  PUBLIC SECTION.
    "! Generate Object Generator
    "! @parameter result | Object Generator
    CLASS-METHODS create_object_generator
      RETURNING VALUE(result) TYPE REF TO zif_mia_object_generator.

    "! Generate Name Generator
    "! @parameter result | Name Generator
    CLASS-METHODS create_name_generator
      RETURNING VALUE(result) TYPE REF TO zif_mia_name_generator.
ENDCLASS.


CLASS zcl_mia_core_factory IMPLEMENTATION.
  METHOD create_object_generator.
    RETURN NEW zcl_mia_object_generator( ).
  ENDMETHOD.


  METHOD create_name_generator.
    RETURN NEW zcl_mia_name_generator( ).
  ENDMETHOD.
ENDCLASS.
