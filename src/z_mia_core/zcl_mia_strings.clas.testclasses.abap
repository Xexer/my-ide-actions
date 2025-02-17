CLASS ltc_utility DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS prefix_from_zlocal      FOR TESTING.
    METHODS prefix_from_ylocal      FOR TESTING.
    METHODS prefix_from_namespace   FOR TESTING.
    METHODS prefix_from_nspac_error FOR TESTING.
ENDCLASS.


CLASS ltc_utility IMPLEMENTATION.
  METHOD prefix_from_zlocal.
    DATA(result) = zcl_mia_strings=>get_prefix_from_package( 'ZLOCAL' ).

    cl_abap_unit_assert=>assert_equals( exp = 'Z'
                                        act = result ).
  ENDMETHOD.


  METHOD prefix_from_ylocal.
    DATA(result) = zcl_mia_strings=>get_prefix_from_package( 'YLOCAL' ).

    cl_abap_unit_assert=>assert_equals( exp = 'Y'
                                        act = result ).
  ENDMETHOD.


  METHOD prefix_from_namespace.
    DATA(result) = zcl_mia_strings=>get_prefix_from_package( '/NSPAC/LOCAL' ).

    cl_abap_unit_assert=>assert_equals( exp = '/NSPAC/'
                                        act = result ).
  ENDMETHOD.


  METHOD prefix_from_nspac_error.
    DATA(result) = zcl_mia_strings=>get_prefix_from_package( '/NSPACLOCAL' ).

    cl_abap_unit_assert=>assert_equals( exp = 'Z'
                                        act = result ).
  ENDMETHOD.
ENDCLASS.
