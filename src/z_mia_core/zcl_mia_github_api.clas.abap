CLASS zcl_mia_github_api DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_mia_github_api.
ENDCLASS.


CLASS zcl_mia_github_api IMPLEMENTATION.
  METHOD zif_mia_github_api~load_raw_file.
    TRY.
        DATA(final_uri) = zif_mia_github_api=>github_raw && path.
        DATA(destination) = cl_http_destination_provider=>create_by_url( final_uri ).
        DATA(client) = cl_web_http_client_manager=>create_by_http_destination( destination ).

        DATA(response) = client->execute( i_method = if_web_http_client=>get ).
        DATA(status) = response->get_status( ).

        IF status-code = 200.
          result = response->get_text( ).
        ENDIF.

      CATCH cx_root.
        CLEAR result.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
