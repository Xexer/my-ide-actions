CLASS ltc_utility_package DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS prefix_from_zlocal      FOR TESTING.
    METHODS prefix_from_ylocal      FOR TESTING.
    METHODS prefix_from_namespace   FOR TESTING.
    METHODS prefix_from_nspac_error FOR TESTING.
ENDCLASS.


CLASS ltc_utility_package IMPLEMENTATION.
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


CLASS ltc_utility_source DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS get_select_statement FOR TESTING.
ENDCLASS.


CLASS ltc_utility_source IMPLEMENTATION.
  METHOD get_select_statement.
    DATA(sources) = VALUE string_table(
        ( `CLASS zcl_bs_demo_swh_tool DEFINITION` )
        ( `  PUBLIC FINAL` )
        ( `  CREATE PUBLIC.` )
        ( `` )
        ( `  PUBLIC SECTION.` )
        ( `    INTERFACES if_oo_adt_classrun.` )
        ( `ENDCLASS.` )
        ( `` )
        ( `` )
        ( `CLASS zcl_bs_demo_swh_tool IMPLEMENTATION.` )
        ( `  METHOD if_oo_adt_classrun~main.` )
        ( |    DATA(statement) = \|SELECT * FROM bkpf\\n  INTO CORRESPONDING FIELDS OF TABLE rt_result\\n  WHERE ( bukrs = '0| &&
        |139'\\n     OR bukrs = '0140' )\\n    AND gjahr = p_gjahr.\|.| )
        ( `` )
        ( `    DATA(result) = zcl_mia_core_factory=>create_swh_tools( )->convert_select_statement( request = VALUE #(` )
        ( `                                                                                            statement  = statement` )
        ( |                                                                                            abap_cloud = abap_t| &&
        |rue ) ).| )
        ( `` )
        ( `    SELECT * FROM bkpf` )
        ( `  INTO CORRESPONDING FIELDS OF TABLE rt_result` )
        ( `  WHERE ( bukrs = '0139'` )
        ( `     OR bukrs = '0140' )` )
        ( `    AND gjahr = p_gjahr.` )
        ( `` )
        ( `    out->write( result-success ).` )
        ( `    out->write( result-error_code ).` )
        ( `    out->write( result-http_code ).` )
        ( `    out->write( result-data-new_statement ).` )
        ( `    out->write( result-data-errors ).` )
        ( `  ENDMETHOD.` )
        ( `ENDCLASS.` ) ).

    DATA(result) = zcl_mia_strings=>extract_statement( statement = `SELECT`
                                                       sources   = sources
                                                       start     = VALUE #( line   = '20'
                                                                            offset = '19' ) ).

    cl_abap_unit_assert=>assert_true( result-found ).
    cl_abap_unit_assert=>assert_equals(
        exp = `SELECT * FROM bkpf  INTO CORRESPONDING FIELDS OF TABLE rt_result  WHERE ( bukrs = '0139'     OR bukrs = '0140' )    AND gjahr = p_gjahr.`
        act = result-statement ).
  ENDMETHOD.
ENDCLASS.
