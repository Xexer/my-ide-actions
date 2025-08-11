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
                         zif_mia_object_link~get_adt_for_interface( object )
                       WHEN zif_mia_object_link=>supported_objects-service_binding THEN
                         zif_mia_object_link~get_adt_for_service_binding( object )
                       WHEN zif_mia_object_link=>supported_objects-service_definition THEN
                         zif_mia_object_link~get_adt_for_service_definition( object )
                       WHEN zif_mia_object_link=>supported_objects-behavior THEN
                         zif_mia_object_link~get_adt_for_behavior( object )
                       WHEN zif_mia_object_link=>supported_objects-cds THEN
                         zif_mia_object_link~get_adt_for_cds( object )
                       WHEN zif_mia_object_link=>supported_objects-database_table THEN
                         zif_mia_object_link~get_adt_for_database_table( object )
                       WHEN zif_mia_object_link=>supported_objects-metadata THEN
                         zif_mia_object_link~get_adt_for_metadata( object ) ).

    DATA(system_id) = sy-sysid.

    RETURN |<a href="adt://{ system_id }{ result }">{ to_upper( object ) }</a>|.
  ENDMETHOD.


  METHOD zif_mia_object_link~get_adt_for_class.
    RETURN |/sap/bc/adt/oo/classes/{ to_lower( object ) }/source/main|.
  ENDMETHOD.


  METHOD zif_mia_object_link~get_adt_for_interface.
    RETURN |/sap/bc/adt/oo/interfaces/{ to_lower( object ) }/source/main|.
  ENDMETHOD.


  METHOD zif_mia_object_link~get_adt_for_service_binding.
    RETURN |/sap/bc/adt/businessservices/bindings/{ to_lower( object ) }|.
  ENDMETHOD.


  METHOD zif_mia_object_link~get_adt_for_service_definition.
    RETURN |/sap/bc/adt/ddic/srvd/sources/{ to_lower( object ) }/source/main|.
  ENDMETHOD.


  METHOD zif_mia_object_link~get_adt_for_behavior.
    RETURN |/sap/bc/adt/bo/behaviordefinitions/{ to_lower( object ) }/source/main|.
  ENDMETHOD.


  METHOD zif_mia_object_link~get_adt_for_cds.
    RETURN |/sap/bc/adt/ddic/ddl/sources/{ to_lower( object ) }/source/main|.
  ENDMETHOD.


  METHOD zif_mia_object_link~get_adt_for_database_table.
    RETURN |/sap/bc/adt/ddic/tables/{ to_lower( object ) }/source/main|.
  ENDMETHOD.


  METHOD zif_mia_object_link~get_adt_for_metadata.
    RETURN |/sap/bc/adt/ddic/ddlx/sources/{ to_lower( object ) }/source/main|.
  ENDMETHOD.
ENDCLASS.
