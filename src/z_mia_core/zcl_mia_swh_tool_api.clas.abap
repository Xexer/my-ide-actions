CLASS zcl_mia_swh_tool_api DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_mia_swh_tool_api.

  PRIVATE SECTION.
    CONSTANTS api_endpoint TYPE string VALUE `https://software-heroes.com/api/v1/abap-tools/`.
    CONSTANTS api_key      TYPE string VALUE `67CD5~8A86DDAF1364~71388`.

    CONSTANTS: BEGIN OF endpoints,
                 convert_select TYPE string VALUE `convert`,
               END OF endpoints.

    METHODS call_api_endpoint
      IMPORTING uri     TYPE string
      CHANGING  !result TYPE any
      RAISING   zcx_mia_error.

    METHODS get_uri
      IMPORTING endpoint      TYPE string
                !parameter    TYPE string
      RETURNING VALUE(result) TYPE string.
ENDCLASS.


CLASS zcl_mia_swh_tool_api IMPLEMENTATION.
  METHOD zif_mia_swh_tool_api~convert_select_statement.
    DATA(base64_statement) = cl_web_http_utility=>encode_base64( request-statement ).

    DATA(uri) = get_uri(
        endpoint  = endpoints-convert_select
        parameter = |statement={ base64_statement }&abap-cloud={ request-abap_cloud }| ).

    TRY.
        call_api_endpoint( EXPORTING uri    = uri
                           CHANGING  result = result ).

      CATCH zcx_mia_error INTO data(error).
        RETURN VALUE #( http_code  = 400
                        error_code = error->previous->get_text( ) ).
    ENDTRY.
  ENDMETHOD.


  METHOD call_api_endpoint.
    TRY.
        DATA(destination) = cl_http_destination_provider=>create_by_url( uri ).
        DATA(client) = cl_web_http_client_manager=>create_by_http_destination( destination ).
        client->get_http_request( )->set_header_field( i_name  = 'Swh-API-Key'
                                                       i_value = api_key ).

        DATA(response) = client->execute( i_method = if_web_http_client=>get ).

        DATA(json) = response->get_text( ).
        IF json IS NOT INITIAL.
          /ui2/cl_json=>deserialize( EXPORTING json = response->get_text( )
                                     CHANGING  data = result ).
        ENDIF.

      CATCH cx_root INTO DATA(error).
        RAISE EXCEPTION NEW zcx_mia_error( previous = error ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_uri.
    RETURN |{ api_endpoint }{ endpoint }?{ parameter }|.
  ENDMETHOD.
ENDCLASS.
