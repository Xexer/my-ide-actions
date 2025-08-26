CLASS zcl_mia_rap_anaylzer_action DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_aia_action.

ENDCLASS.


CLASS zcl_mia_rap_anaylzer_action IMPLEMENTATION.
  METHOD if_aia_action~run.
    DATA(resource) = context->get_focused_resource( ).
    DATA(analyzer) = zcl_mia_core_factory=>create_rap_analyzer( resource->get_name( ) ).

    DATA(rap_object) = analyzer->get_rap_object( ).
    DATA(html_content) = zcl_mia_core_factory=>create_html_output( )->generate_rap_object( rap_object ).

    DATA(html_output) = cl_aia_result_factory=>create_html_popup_result( ).
    html_output->set_content( html_content ).

    result = html_output.
  ENDMETHOD.
ENDCLASS.
