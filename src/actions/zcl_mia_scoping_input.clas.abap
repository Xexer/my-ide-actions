CLASS zcl_mia_scoping_input DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_sd_action_input.

    CONSTANTS:
      BEGIN OF scope_change,
        "! <p class="shorttext">On</p>
        on  TYPE if_aps_bc_scope_change_api=>ts_object_scope-scope_state VALUE if_aps_bc_scope_change_api=>gc_scope_state-on,
        "! <p class="shorttext">Off</p>
        off TYPE if_aps_bc_scope_change_api=>ts_object_scope-scope_state VALUE if_aps_bc_scope_change_api=>gc_scope_state-off,
      END OF scope_change.

    "! $values { @link zcl_mia_scoping_input.data:scope_change }
    "! $default { @link zcl_mia_scoping_input.data:scope_change.on }
    TYPES scope TYPE if_aps_bc_scope_change_api=>ts_object_scope-scope_state.

    TYPES:
      "! <p class="shorttext">Change scope</p>
      BEGIN OF input,
        "! <p class="shorttext">Change</p>
        change TYPE scope,
      END OF input.
ENDCLASS.


CLASS zcl_mia_scoping_input IMPLEMENTATION.
  METHOD if_aia_sd_action_input~create_input_config.
    DATA input TYPE input.

    RETURN ui_information_factory->for_abap_type( abap_type = input ).
  ENDMETHOD.
ENDCLASS.
