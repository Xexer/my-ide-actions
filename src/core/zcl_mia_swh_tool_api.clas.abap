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

    "! Call the Software-Heroes API endpoint and execute action
    "! @parameter uri           | URI of the API
    "! @parameter payload       | Payload in JSON format
    "! @parameter result        | Result JSON from the API call
    "! @raising   zcx_mia_error | Error
    METHODS call_api_endpoint
      IMPORTING uri     TYPE string
                payload TYPE string
      CHANGING  !result TYPE any
      RAISING   zcx_mia_error.

    "! Create URL for the API call
    "! @parameter endpoint | Path of the endpoint
    "! @parameter result   | Full path
    METHODS get_uri
      IMPORTING endpoint      TYPE string
      RETURNING VALUE(result) TYPE string.
ENDCLASS.


CLASS zcl_mia_swh_tool_api IMPLEMENTATION.
  METHOD zif_mia_swh_tool_api~convert_select_statement.
    DATA(local_request) = request.
    local_request-statement = cl_web_http_utility=>encode_base64( local_request-statement ).

    DATA(uri) = get_uri( endpoints-convert_select ).
    DATA(payload) = /ui2/cl_json=>serialize( data        = local_request
                                             pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

    TRY.
        call_api_endpoint( EXPORTING uri     = uri
                                     payload = payload
                           CHANGING  result  = result ).

        result-data-new_statement = cl_web_http_utility=>decode_base64( result-data-new_statement ).

      CATCH zcx_mia_error INTO DATA(error).
        RETURN VALUE #( http_code  = 400
                        error_code = error->previous->get_text( ) ).
    ENDTRY.
  ENDMETHOD.


  METHOD call_api_endpoint.
    TRY.
        DATA(destination) = cl_http_destination_provider=>create_by_url( uri ).
        DATA(client) = cl_web_http_client_manager=>create_by_http_destination( destination ).

        DATA(request) = client->get_http_request( ).
        request->set_header_field( i_name  = 'Swh-API-Key'
                                   i_value = api_key ).
        request->set_content_type( `application/json` ).
        request->set_text( payload ).

        DATA(response) = client->execute( i_method = if_web_http_client=>post ).
        DATA(status) = response->get_status( ).
        DATA(json) = response->get_text( ).

        IF json IS NOT INITIAL AND status-code = 200.
          /ui2/cl_json=>deserialize( EXPORTING json = response->get_text( )
                                     CHANGING  data = result ).
        ENDIF.

      CATCH cx_root INTO DATA(error).
        RAISE EXCEPTION NEW zcx_mia_error( previous = error ).
    ENDTRY.
  ENDMETHOD.


  METHOD get_uri.
    RETURN |{ api_endpoint }{ endpoint }|.
  ENDMETHOD.
ENDCLASS.
