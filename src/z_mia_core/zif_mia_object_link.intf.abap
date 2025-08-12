INTERFACE zif_mia_object_link
  PUBLIC.

  CONSTANTS: BEGIN OF supported_objects,
               class              TYPE string VALUE `CLAS`,
               interface          TYPE string VALUE `INTF`,
               service_binding    TYPE string VALUE `SRVB`,
               service_definition TYPE string VALUE `SRVD`,
               metadata           TYPE string VALUE `DDLX`,
               behavior           TYPE string VALUE `BEHV`,
               database_table     TYPE string VALUE `TABL`,
               cds                TYPE string VALUE `DDL`,
               domain             TYPE string VALUE `DOMA`,
             END OF supported_objects.

  "! Build HTML link for object
  "! @parameter object_type | Type of object
  "! @parameter object      | Name of the object
  "! @parameter result      | HTML link
  METHODS get_hmtl_link_for_object
    IMPORTING object_type   TYPE string
              !object       TYPE csequence
    RETURNING VALUE(result) TYPE string.

  "! Build ADT link for class
  "! @parameter object | Name of the object
  "! @parameter result | ADT link
  METHODS get_adt_for_class
    IMPORTING !object       TYPE csequence
    RETURNING VALUE(result) TYPE string.

  "! Build ADT link for interface
  "! @parameter object | Name of the object
  "! @parameter result | ADT link
  METHODS get_adt_for_interface
    IMPORTING !object       TYPE csequence
    RETURNING VALUE(result) TYPE string.

  "! Build ADT link for service binding
  "! @parameter object | Name of the object
  "! @parameter result | ADT link
  METHODS get_adt_for_service_binding
    IMPORTING !object       TYPE csequence
    RETURNING VALUE(result) TYPE string.

  "! Build ADT link for service definition
  "! @parameter object | Name of the object
  "! @parameter result | ADT link
  METHODS get_adt_for_service_definition
    IMPORTING !object       TYPE csequence
    RETURNING VALUE(result) TYPE string.

  "! Build ADT link for metadata
  "! @parameter object | Name of the object
  "! @parameter result | ADT link
  METHODS get_adt_for_metadata
    IMPORTING !object       TYPE csequence
    RETURNING VALUE(result) TYPE string.

  "! Build ADT link for behavior
  "! @parameter object | Name of the object
  "! @parameter result | ADT link
  METHODS get_adt_for_behavior
    IMPORTING !object       TYPE csequence
    RETURNING VALUE(result) TYPE string.

  "! Build ADT link for database table
  "! @parameter object | Name of the object
  "! @parameter result | ADT link
  METHODS get_adt_for_database_table
    IMPORTING !object       TYPE csequence
    RETURNING VALUE(result) TYPE string.

  "! Build ADT link for core data service
  "! @parameter object | Name of the object
  "! @parameter result | ADT link
  METHODS get_adt_for_cds
    IMPORTING !object       TYPE csequence
    RETURNING VALUE(result) TYPE string.

  "! Build ADT link for domain
  "! @parameter object | Name of the object
  "! @parameter result | ADT link
  METHODS get_adt_for_domain
    IMPORTING !object       TYPE csequence
    RETURNING VALUE(result) TYPE string.
ENDINTERFACE.
