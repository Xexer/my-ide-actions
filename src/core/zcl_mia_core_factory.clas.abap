CLASS zcl_mia_core_factory DEFINITION
  PUBLIC ABSTRACT FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    "! Generate Object Generator
    "! @parameter result | Object Generator
    CLASS-METHODS create_object_generator
      RETURNING VALUE(result) TYPE REF TO zif_mia_object_generator.

    "! Generate HTML Output for RAP
    "! @parameter result | HTML Output
    CLASS-METHODS create_rap_output
      RETURNING VALUE(result) TYPE REF TO zif_mia_html_rap.

    "! Generate RAP Analyzer Tool
    "! @parameter object_name | Name of the object
    "! @parameter object_type | Type of the object
    "! @parameter result      | RAP Analyzer
    CLASS-METHODS create_rap_analyzer
      IMPORTING object_name   TYPE string
                object_type   TYPE string
      RETURNING VALUE(result) TYPE REF TO zif_mia_rap_analyzer.

    "! Generate Name Generator
    "! @parameter result | Name Generator
    CLASS-METHODS create_name_generator
      RETURNING VALUE(result) TYPE REF TO zif_mia_name_generator.

    "! Generate HTML Output Object
    "! @parameter result | HTML Output
    CLASS-METHODS create_html_output
      RETURNING VALUE(result) TYPE REF TO zif_mia_html_output.

    "! Generate SwH-Tool Access
    "! @parameter result | Tool Access
    CLASS-METHODS create_swh_tools
      RETURNING VALUE(result) TYPE REF TO zif_mia_swh_tool_api.

    "! Generate access to GitHub
    "! @parameter result | GitHub Actions
    CLASS-METHODS create_github_access
      RETURNING VALUE(result) TYPE REF TO zif_mia_github_api.

    "! Generate class analyzer for Consumption Models
    "! @parameter class_name | Name of the class
    "! @parameter result     | Class analyzer
    CLASS-METHODS create_class_analyzer
      IMPORTING class_name    TYPE zif_mia_class_analyzer=>class_name
      RETURNING VALUE(result) TYPE REF TO zif_mia_class_analyzer.

    "! Generate Object Link Creator
    "! @parameter result | Object Link Creator
    CLASS-METHODS create_object_link
      RETURNING VALUE(result) TYPE REF TO zif_mia_object_link.
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


  METHOD create_swh_tools.
    RETURN NEW zcl_mia_swh_tool_api( ).
  ENDMETHOD.


  METHOD create_github_access.
    RETURN NEW zcl_mia_github_api( ).
  ENDMETHOD.


  METHOD create_class_analyzer.
    RETURN NEW zcl_mia_class_analyzer( class_name ).
  ENDMETHOD.


  METHOD create_object_link.
    RETURN NEW zcl_mia_object_link( ).
  ENDMETHOD.


  METHOD create_rap_analyzer.
    RETURN NEW zcl_mia_rap_analyzer( object_name = object_name
                                     object_type = object_type ).
  ENDMETHOD.


  METHOD create_rap_output.
    RETURN NEW zcl_mia_html_rap( ).
  ENDMETHOD.
ENDCLASS.
