INTERFACE zif_mia_object_generator
  PUBLIC.

  TYPES prefix TYPE c LENGTH 10.

  TYPES: BEGIN OF setting,
           prefix      TYPE prefix,
           name        TYPE sxco_ao_object_name,
           description TYPE if_xco_cp_gen_intf_s_form=>tv_short_description,
           transport   TYPE sxco_transport,
           package     TYPE sxco_package,
           inst_name   TYPE sxco_ao_object_name,
           interface   TYPE sxco_ao_object_name,
           class       TYPE sxco_ao_object_name,
           factory     TYPE sxco_ao_object_name,
           injector    TYPE sxco_ao_object_name,
         END OF setting.

  TYPES: BEGIN OF generation_result,
           success        TYPE abap_boolean,
           findings       TYPE REF TO if_xco_gen_o_findings,
           findings_patch TYPE REF TO if_xco_gen_o_findings,
           messages       TYPE sxco_t_messages,
           transport      TYPE sxco_transport,
           package        TYPE sxco_package,
           interface      TYPE sxco_ao_object_name,
           class          TYPE sxco_ao_object_name,
           factory        TYPE sxco_ao_object_name,
           injector       TYPE sxco_ao_object_name,
         END OF generation_result.

  TYPES:
    BEGIN OF package_setting,
      package   TYPE sxco_package,
      transport TYPE sxco_transport,
      x_app     TYPE abap_boolean,
      app_1     TYPE string,
      app_2     TYPE string,
      app_3     TYPE string,
      x_intf    TYPE abap_boolean,
      intf_1    TYPE string,
      intf_2    TYPE string,
      intf_3    TYPE string,
      x_fiori   TYPE abap_boolean,
      x_reuse   TYPE abap_boolean,
      x_share   TYPE abap_boolean,
      x_test    TYPE abap_boolean,
    END OF package_setting.

  TYPES: BEGIN OF generation_result_package,
           object TYPE string,
         END OF generation_result_package.
  TYPES generation_result_packages TYPE STANDARD TABLE OF generation_result_package WITH EMPTY KEY.

  "! Generate Objects from settings
  "! @parameter setting | Settings
  "! @parameter result  | Result from generation
  METHODS generate_objects_via_setting
    IMPORTING setting       TYPE setting
    RETURNING VALUE(result) TYPE generation_result.

  "! Generate package structure for input
  "! @parameter setting | Settings
  "! @parameter result  | Result of Generation
  METHODS generate_package_structure
    IMPORTING setting       TYPE package_setting
    RETURNING VALUE(result) TYPE generation_result_packages.

ENDINTERFACE.
