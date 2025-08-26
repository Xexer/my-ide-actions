CLASS zcl_mia_selectconvert_action DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_action.

ENDCLASS.


CLASS zcl_mia_selectconvert_action IMPLEMENTATION.
  METHOD if_aia_action~run.
    TRY.
        DATA(resource) = CAST if_adt_context_src_based_obj( context->get_focused_resource( ) ).
        DATA(sources) = resource->get_source_code( ).
        DATA(position) = resource->get_position( ).

        DATA(extraction) = zcl_mia_strings=>extract_statement( statement = `SELECT`
                                                               sources   = sources
                                                               start     = position->pos-start ).
        IF extraction-found = abap_false.
          RAISE EXCEPTION NEW zcx_mia_error( ).
        ENDIF.

        DATA(conversion) = zcl_mia_core_factory=>create_swh_tools( )->convert_select_statement(
            request = VALUE #( statement  = extraction-statement
                               abap_cloud = abap_true ) ).
        IF conversion-success = abap_false.
          RAISE EXCEPTION NEW zcx_mia_error( ).
        ENDIF.

        DATA(change_result) = cl_aia_result_factory=>create_source_change_result( ).
        change_result->add_code_replacement_delta( content            = conversion-data-new_statement
                                                   selection_position = position ).
        result = change_result.

      CATCH cx_adt_context_dynamic cx_adt_context_unauthorized zcx_mia_error INTO DATA(error).
        DATA(popup_result) = cl_aia_result_factory=>create_text_popup_result( ).
        popup_result->set_content( |{ TEXT-001 }: { error->get_text( ) }| ).
        result = popup_result.

    ENDTRY.
  ENDMETHOD.
ENDCLASS.
