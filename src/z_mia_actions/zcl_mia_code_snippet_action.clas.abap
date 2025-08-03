CLASS zcl_mia_code_snippet_action DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_action.

    CONSTANTS: BEGIN OF supported_types,
                 class    TYPE string VALUE `CLAS`,
                 behavior TYPE string VALUE `BDEF`,
                 cds      TYPE string VALUE `DDLS`,
                 table    TYPE string VALUE `TABL`,
               END OF supported_types.

  PRIVATE SECTION.
    CONSTANTS github_path        TYPE string VALUE `/Xexer/abap-code-snippets/refs/heads/main/snippets/`.
    CONSTANTS github_file_format TYPE string VALUE `.txt`.

    METHODS get_snippet
      IMPORTING template      TYPE string
      RETURNING VALUE(result) TYPE string.
ENDCLASS.


CLASS zcl_mia_code_snippet_action IMPLEMENTATION.
  METHOD if_aia_action~run.
    DATA input TYPE zcl_mia_code_snippet_input=>input.

    TRY.
        context->get_input_config_content( )->get_as_structure( IMPORTING result = input ).

      CATCH cx_sd_invalid_data.
        DATA(error_result) = cl_aia_result_factory=>create_text_popup_result( ).
        error_result->set_content( CONV #( TEXT-001 ) ).
        result = error_result.
        RETURN.
    ENDTRY.

    DATA(resource) = CAST if_adt_context_src_based_obj( context->get_focused_resource( ) ).
    DATA(position) = resource->get_position( ).

    DATA(snippet_data) = get_snippet( input-template ).

    DATA(change_result) = cl_aia_result_factory=>create_source_change_result( ).
    change_result->add_code_replacement_delta( content            = snippet_data
                                               selection_position = position ).
    result = change_result.
  ENDMETHOD.


  METHOD get_snippet.
    DATA(github) = zcl_mia_core_factory=>create_github_access( ).
    DATA(path) = github_path && template && github_file_format.
    RETURN github->load_raw_file( path ).
  ENDMETHOD.
ENDCLASS.
