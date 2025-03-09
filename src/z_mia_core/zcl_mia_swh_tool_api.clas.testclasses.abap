CLASS ltc_select_converter DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS convert_simple_statement FOR TESTING.
    METHODS convert_no_statement     FOR TESTING.
ENDCLASS.


CLASS ltc_select_converter IMPLEMENTATION.
  METHOD convert_simple_statement.
    DATA(statement) = |SELECT * FROM bkpf\n  INTO CORRESPONDING FIELDS OF TABLE rt_result\n  WHERE ( bukrs = '0139'\n     OR bukrs = '0140' )\n    AND gjahr = p_gjahr.|.

    DATA(result) = zcl_mia_core_factory=>create_swh_tools( )->convert_select_statement( request = VALUE #(
                                                                                            statement  = statement
                                                                                            abap_cloud = abap_true
                                                                                            new_syntax = abap_false ) ).

    cl_abap_unit_assert=>assert_true( result-success ).
    cl_abap_unit_assert=>assert_equals(
        exp = |SELECT * FROM I_JOURNALENTRY\n  INTO CORRESPONDING FIELDS OF TABLE rt_result\n  WHERE ( CompanyCode = '0139'\n     OR CompanyCode = '0140' )\n    AND FiscalYear = p_gjahr.|
        act = result-data-new_statement ).
  ENDMETHOD.


  METHOD convert_no_statement.
    DATA(result) = zcl_mia_core_factory=>create_swh_tools( )->convert_select_statement( request = VALUE #(
                                                                                            statement  = `SELECT`
                                                                                            abap_cloud = abap_true
                                                                                            new_syntax = abap_false ) ).

    cl_abap_unit_assert=>assert_false( result-success ).
    cl_abap_unit_assert=>assert_equals( exp = `FIELD_VALIDATION_FAILED`
                                        act = result-error_code ).
  ENDMETHOD.
ENDCLASS.
