INTERFACE zif_mia_object_link
  PUBLIC.

  CONSTANTS: BEGIN OF supported_objects,
               class     TYPE string VALUE `CLAS`,
               interface TYPE string VALUE `INTF`,
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
ENDINTERFACE.
