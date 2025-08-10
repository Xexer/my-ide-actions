CLASS zcl_mia_object_link DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_mia_object_link.
ENDCLASS.


CLASS zcl_mia_object_link IMPLEMENTATION.
  METHOD zif_mia_object_link~get_hmtl_link_for_object.
    result = SWITCH #( object_type
                       WHEN zif_mia_object_link=>supported_objects-class THEN
                         zif_mia_object_link~get_adt_for_class( object )
                       WHEN zif_mia_object_link=>supported_objects-interface THEN
                         zif_mia_object_link~get_adt_for_interface( object ) ).

    DATA(system_id) = sy-sysid.

    RETURN |<a href="adt://{ system_id }{ result }">{ to_upper( object ) }</a>|.
  ENDMETHOD.


  METHOD zif_mia_object_link~get_adt_for_class.
    RETURN |/sap/bc/adt/oo/classes/{ to_lower( object ) }/source/main|.
  ENDMETHOD.


  METHOD zif_mia_object_link~get_adt_for_interface.
    RETURN |/sap/bc/adt/oo/interfaces/{ to_lower( object ) }/source/main|.
  ENDMETHOD.
ENDCLASS.
