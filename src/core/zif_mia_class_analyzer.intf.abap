INTERFACE zif_mia_class_analyzer
  PUBLIC.

  TYPES class_name TYPE sxco_ao_object_name.

  TYPES: BEGIN OF structure_type,
           name  TYPE string,
           type  TYPE string,
           key   TYPE abap_boolean,
           label TYPE string,
         END OF structure_type.
  TYPES structure_types TYPE STANDARD TABLE OF structure_type WITH EMPTY KEY.

  "! Checks if the class has the superclass "'/IWBEP/CL_V4_ABS_PM_MODEL_PROV'"
  "! @parameter result | X = Is consumption class, '' = Other class
  METHODS is_consumption_model
    RETURNING VALUE(result) TYPE abap_boolean.

  "! Get all types that are structures
  "! @parameter result | List of types
  METHODS get_types
    RETURNING VALUE(result) TYPE structure_types.

  "! Get all fields for the structure
  "! @parameter type_name | Name of the type
  "! @parameter result    | List of field names and types
  METHODS get_structure_for_type
    IMPORTING type_name     TYPE string
    RETURNING VALUE(result) TYPE structure_types.
ENDINTERFACE.
