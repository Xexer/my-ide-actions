INTERFACE zif_mia_rap_analyzer
  PUBLIC.

  TYPES:
    BEGIN OF entity,
      name        TYPE string,
      type        TYPE string,
      description TYPE string,
      alias       TYPE string,
      root        TYPE abap_boolean,
      loaded      TYPE abap_boolean,
      not_found   TYPE abap_boolean,
      database    TYPE string,
      parent      TYPE string,
      package     TYPE string,
    END OF entity.
  TYPES entities TYPE STANDARD TABLE OF entity WITH EMPTY KEY.

  TYPES:
    BEGIN OF rap_child,
      cds_entity   TYPE string,
      table        TYPE string,
      metadata     TYPE string,
      parent       TYPE string,
      parent_child TYPE string,
    END OF rap_child.
  TYPES rap_childs TYPE STANDARD TABLE OF rap_child WITH EMPTY KEY.

  TYPES:
    BEGIN OF rap_layer,
      cds_entity TYPE string,
      table      TYPE string,
      behavior   TYPE string,
      metadata   TYPE string,
      childs     TYPE rap_childs,
    END OF rap_layer.

  TYPES:
    BEGIN OF rap_object,
      name               TYPE string,
      classification     TYPE string,
      base               TYPE rap_layer,
      consumption        TYPE rap_layer,
      service_definition TYPE string,
      service_binding    TYPE string,
      domains            TYPE string_table,
    END OF rap_object.

  CONSTANTS:
    BEGIN OF types,
      service_binding    TYPE string VALUE `SERVICE_BINDING`,
      service_definition TYPE string VALUE `SERVICE_DEFINITION`,
      metadata           TYPE string VALUE `METADATA_EXTENSION`,
      behavior           TYPE string VALUE `BEHAVIOR`,
      cds                TYPE string VALUE `CDS`,
      table              TYPE string VALUE `TABLE`,
      domain             TYPE string VALUE `DOMAIN`,
    END OF types.

  CONSTANTS:
    BEGIN OF classifications,
      standard TYPE string VALUE `STANDARD`,
      custom   TYPE string VALUE `CUSTOM`,
    END OF classifications.

  "! Checks the service and returns all objects bellow
  "! @parameter result | List of objects
  METHODS get_objects_in_stack
    RETURNING VALUE(result) TYPE entities.

  "! Returns the RAP object
  "! @parameter result | RAP Objects structure
  METHODS get_rap_object
    RETURNING VALUE(result) TYPE rap_object.
ENDINTERFACE.
