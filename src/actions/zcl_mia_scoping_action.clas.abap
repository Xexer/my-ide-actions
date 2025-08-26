CLASS zcl_mia_scoping_action DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_action.

  PRIVATE SECTION.
    TYPES object_name TYPE c LENGTH 40.
    TYPES objects     TYPE STANDARD TABLE OF object_name WITH EMPTY KEY.
    TYPES: BEGIN OF scope_result,
             pgmid               TYPE if_aps_bc_scope_change_api=>ts_tadir_key-pgmid,
             object              TYPE if_aps_bc_scope_change_api=>ts_tadir_key-object,
             obj_name            TYPE if_aps_bc_scope_change_api=>ts_tadir_key-obj_name,
             scope_state_changed TYPE abap_boolean,
             scope_state         TYPE if_aps_bc_scope_change_api=>ts_object_scope-scope_state,
             message_out         TYPE string,
           END OF scope_result.
    TYPES scope_results TYPE STANDARD TABLE OF scope_result WITH EMPTY KEY.

    METHODS scope_content
      IMPORTING !pages        TYPE objects
                spaces        TYPE objects
                scope_state   TYPE if_aps_bc_scope_change_api=>ts_object_scope-scope_state
      RETURNING VALUE(result) TYPE scope_results.
ENDCLASS.


CLASS zcl_mia_scoping_action IMPLEMENTATION.
  METHOD if_aia_action~run.
    DATA input           TYPE zcl_mia_scoping_input=>input.
    DATA selected_pages  TYPE objects.
    DATA selected_spaces TYPE objects.

    TRY.
        context->get_input_config_content( )->get_as_structure( IMPORTING result = input ).
      CATCH cx_sd_invalid_data.
        RETURN.
    ENDTRY.

    LOOP AT context->get_focused_resources( ) INTO DATA(focused_object).
      CASE focused_object->get_type( ).
        WHEN 'UIPG/TYP'.
          INSERT CONV #( focused_object->get_name( ) ) INTO TABLE selected_pages.
        WHEN 'UIST/TOP'.
          INSERT CONV #( focused_object->get_name( ) ) INTO TABLE selected_spaces.
      ENDCASE.
    ENDLOOP.

    DATA(scope_result) = scope_content( pages       = selected_pages
                                        spaces      = selected_spaces
                                        scope_state = input-change ).

    DATA(html_generator) = zcl_mia_core_factory=>create_html_output( ).
    DATA(html_content) = html_generator->generate_generic_output( REF #( scope_result ) ).
    DATA(html_output) = cl_aia_result_factory=>create_html_popup_result( ).
    html_output->set_content( html_content ).

    result = html_output.
  ENDMETHOD.


  METHOD scope_content.
    DATA scopes TYPE if_aps_bc_scope_change_api=>tt_object_scope_sorted.

    DATA(scope_api) = cl_aps_bc_scope_change_api=>create_instance( ).

    LOOP AT spaces INTO DATA(new_space).
      INSERT VALUE #( pgmid       = if_aps_bc_scope_change_api=>gc_tadir_pgmid-r3tr
                      scope_state = scope_state
                      object      = if_aps_bc_scope_change_api=>gc_tadir_object-uist
                      obj_name    = new_space ) INTO TABLE scopes.
    ENDLOOP.

    LOOP AT pages INTO DATA(new_page).
      INSERT VALUE #( pgmid       = if_aps_bc_scope_change_api=>gc_tadir_pgmid-r3tr
                      scope_state = scope_state
                      object      = if_aps_bc_scope_change_api=>gc_tadir_object-uipg
                      obj_name    = new_page ) INTO TABLE scopes.
    ENDLOOP.

    scope_api->scope( EXPORTING it_object_scope  = scopes
                                iv_simulate      = abap_false
                                iv_force         = abap_true
                      IMPORTING et_object_result = DATA(object_results) ).

    INSERT VALUE #( pgmid               = 'PG'
                    object              = 'Obj'
                    obj_name            = 'Name'
                    scope_state_changed = 'C'
                    scope_state         = 'S'
                    message_out         = 'Message' )
           INTO TABLE result.

    LOOP AT object_results INTO DATA(object_result).
      DATA(result_line) = CORRESPONDING scope_result( object_result ).

      LOOP AT object_result-message INTO DATA(message).
        DATA(xco_message) = xco_cp=>message( VALUE #( msgid = message-id
                                                      msgno = message-number
                                                      msgty = message-type
                                                      msgv1 = message-message_v1
                                                      msgv2 = message-message_v2
                                                      msgv3 = message-message_v3
                                                      msgv4 = message-message_v4 ) ).

        result_line-message_out = xco_message->get_text( ).
        INSERT result_line INTO TABLE result.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
