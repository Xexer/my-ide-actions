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
    TYPES: BEGIN OF replace_tag,
             tag          TYPE string,
             replace_with TYPE string,
           END OF replace_tag.
    TYPES replace_tags TYPE STANDARD TABLE OF replace_tag WITH EMPTY KEY.

    CONSTANTS github_path        TYPE string VALUE `/Xexer/abap-code-snippets/refs/heads/main/snippets/`.
    CONSTANTS github_file_format TYPE string VALUE `.txt`.

    "! Load the code snippet from remote source
    "! @parameter input  | Filled configuration
    "! @parameter result | Code snippet with placeholder
    METHODS get_snippet
      IMPORTING !input        TYPE zcl_mia_code_snippet_input=>input
      RETURNING VALUE(result) TYPE string.

    "! Replace all placeholder in the template
    "! @parameter input   | Values from the input
    "! @parameter content | Code Snippet with placeholder
    "! @parameter result  | Final code snippet
    METHODS replace_placeholder
      IMPORTING !input        TYPE zcl_mia_code_snippet_input=>input
                content       TYPE string
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

    DATA(snippet_data) = get_snippet( input ).
    snippet_data = replace_placeholder( input   = input
                                        content = snippet_data ).

    DATA(change_result) = cl_aia_result_factory=>create_source_change_result( ).
    change_result->add_code_replacement_delta( content            = snippet_data
                                               selection_position = position ).
    result = change_result.
  ENDMETHOD.


  METHOD get_snippet.
    DATA(template) = ``.

    IF input-template_cds IS NOT INITIAL.
      template = input-template_cds.
    ELSEIF input-template_table IS NOT INITIAL.
      template = input-template_table.
    ELSEIF input-template_class IS NOT INITIAL.
      template = input-template_class.
    ELSEIF input-template_behavior IS NOT INITIAL.
      template = input-template_behavior.
    ELSE.
      RETURN.
    ENDIF.

    DATA(github) = zcl_mia_core_factory=>create_github_access( ).
    DATA(path) = github_path && template && github_file_format.
    RETURN github->load_raw_file( path ).
  ENDMETHOD.


  METHOD replace_placeholder.
    DATA(tags) = VALUE replace_tags( ( tag = `ENTITY` replace_with = input-entity )
                                     ( tag = `FIELD` replace_with = input-field )
                                     ( tag = `DATA_ELEMENT` replace_with = input-data_element ) ).

    result = content.
    LOOP AT tags INTO DATA(tag).
      result = replace( val  = result
                        sub  = |[[{ tag-tag }]]|
                        with = tag-replace_with
                        occ  = 0 ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
