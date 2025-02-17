INTERFACE zif_mia_object_generator
  PUBLIC.

  TYPES prefix TYPE c LENGTH 10.

  TYPES: BEGIN OF setting,
           prefix      TYPE prefix,
           name        TYPE sxco_ao_object_name,
           description TYPE if_xco_cp_gen_intf_s_form=>tv_short_description,
           transport   TYPE sxco_transport,
           package     TYPE sxco_package,
           interface   TYPE sxco_ao_object_name,
           class       TYPE sxco_ao_object_name,
           factory     TYPE sxco_ao_object_name,
           injector    TYPE sxco_ao_object_name,
         END OF setting.

  TYPES: BEGIN OF generation_result,
           success   TYPE abap_boolean,
           findings  TYPE REF TO if_xco_gen_o_findings,
           messages  TYPE sxco_t_messages,
           transport TYPE sxco_transport,
           package   TYPE sxco_package,
           interface TYPE sxco_ao_object_name,
           class     TYPE sxco_ao_object_name,
           factory   TYPE sxco_ao_object_name,
           injector  TYPE sxco_ao_object_name,
         END OF generation_result.

  "! Generate Objects from settings
  "! @parameter setting | Settings
  "! @parameter result  | Result from generation
  METHODS generate_objects_via_setting
    IMPORTING setting       TYPE setting
    RETURNING VALUE(result) TYPE generation_result.
ENDINTERFACE.
