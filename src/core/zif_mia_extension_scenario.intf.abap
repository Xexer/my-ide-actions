INTERFACE zif_mia_extension_scenario
  PUBLIC.

  TYPES: BEGIN OF new_field,
           entity TYPE string,
           name   TYPE string,
         END OF new_field.

  TYPES: BEGIN OF step,
           status      TYPE string,
           number      TYPE string,
           option      TYPE string,
           description TYPE string,
           code        TYPE string,
         END OF step.
  TYPES steps TYPE STANDARD TABLE OF step WITH EMPTY KEY.

  CONSTANTS: BEGIN OF options,
               empty    TYPE string VALUE ``,
               optional TYPE string VALUE `OPTIONAL`,
               choose   TYPE string VALUE `CHOOSE`,
             END OF options.

  "! Generate adjustment steps for assistant (new_field)
  "! @parameter new_field | Information for the new field
  "! @parameter result    | Steps for adjustment
  METHODS generate_steps_for_new_field
    IMPORTING new_field     TYPE new_field
    RETURNING VALUE(result) TYPE steps.
ENDINTERFACE.
