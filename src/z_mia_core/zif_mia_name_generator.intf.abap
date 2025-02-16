INTERFACE zif_mia_name_generator
  PUBLIC.

  TYPES object_prefix TYPE c LENGTH 2.

  "! Generate Interface name
  "! @parameter setting       | Settings
  "! @parameter result        | New name
  "! @raising   zcx_mia_error | Name too long
  METHODS generate_interface_name
    IMPORTING setting       TYPE zif_mia_object_generator=>setting
    RETURNING VALUE(result) TYPE sxco_ao_object_name
    RAISING   zcx_mia_error.

  "! Generate Class name
  "! @parameter setting       | Settings
  "! @parameter result        | New name
  "! @raising   zcx_mia_error | Name too long
  METHODS generate_class_name
    IMPORTING setting       TYPE zif_mia_object_generator=>setting
    RETURNING VALUE(result) TYPE sxco_ao_object_name
    RAISING   zcx_mia_error.

  "! Generate Factory name
  "! @parameter setting       | Settings
  "! @parameter result        | New name
  "! @raising   zcx_mia_error | Name too long
  METHODS generate_factory_name
    IMPORTING setting       TYPE zif_mia_object_generator=>setting
    RETURNING VALUE(result) TYPE sxco_ao_object_name
    RAISING   zcx_mia_error.

  "! Generate Injector name
  "! @parameter setting       | Settings
  "! @parameter result        | New name
  "! @raising   zcx_mia_error | Name too long
  METHODS generate_injector_name
    IMPORTING setting       TYPE zif_mia_object_generator=>setting
    RETURNING VALUE(result) TYPE sxco_ao_object_name
    RAISING   zcx_mia_error.
ENDINTERFACE.
