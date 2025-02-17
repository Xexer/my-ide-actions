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

    "! Generate HTML Output Object
    "! @parameter result | HTML Output
    CLASS-METHODS create_html_output
      RETURNING VALUE(result) TYPE REF TO zif_mia_html_output.
ENDCLASS.


CLASS zcl_mia_core_factory IMPLEMENTATION.
  METHOD create_object_generator.
    RETURN NEW zcl_mia_object_generator( ).
  ENDMETHOD.


  METHOD create_name_generator.
    RETURN NEW zcl_mia_name_generator( ).
  ENDMETHOD.


  METHOD create_html_output.
    RETURN NEW zcl_mia_html_output( ).
  ENDMETHOD.
ENDCLASS.
