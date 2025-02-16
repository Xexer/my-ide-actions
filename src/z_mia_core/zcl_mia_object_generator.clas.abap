CLASS zcl_mia_object_generator DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_mia_object_generator.

  PRIVATE SECTION.
    DATA run_setting TYPE zif_mia_object_generator=>setting.

    "! Generate Interface
    "! @parameter operation | XCO Operation
    METHODS generate_interface
      IMPORTING operation TYPE REF TO if_xco_cp_gen_d_o_put.

    "! Generate Class
    "! @parameter operation | XCO Operation
    METHODS genarate_class
      IMPORTING operation TYPE REF TO if_xco_cp_gen_d_o_put.

    "! Generate Factory
    "! @parameter operation | XCO Operation
    METHODS genarate_factory
      IMPORTING operation TYPE REF TO if_xco_cp_gen_d_o_put.

    "! Generate Injector
    "! @parameter operation | XCO Operation
    METHODS genarate_injector
      IMPORTING operation TYPE REF TO if_xco_cp_gen_d_o_put.

    "! Generate factory method with injector
    "! @parameter specification | Class specification
    "! @parameter method_name   | Name of the method
    METHODS add_injector_content
      IMPORTING specification TYPE REF TO if_xco_cp_gen_clas_s_form
                method_name   TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name.

ENDCLASS.


CLASS zcl_mia_object_generator IMPLEMENTATION.
  METHOD zif_mia_object_generator~generate_objects_via_setting.
    run_setting = setting.

    DATA(operation) = xco_cp_generation=>environment->dev_system( run_setting-transport )->create_put_operation( ).

    generate_interface( operation ).
    genarate_class( operation ).
    genarate_factory( operation ).
    genarate_injector( operation ).

    DATA(operation_result) = operation->execute( ). " VALUE #( ( xco_cp_generation=>put_operation_option->skip_activation ) ) ).
    IF operation_result->findings IS INITIAL.
      result-success = abap_true.
    ELSE.
      result-success  = abap_false.
      result-findings = operation_result->findings.
    ENDIF.
  ENDMETHOD.


  METHOD generate_interface.
    IF run_setting-interface IS INITIAL.
      RETURN.
    ENDIF.

    DATA(specification) = operation->for-intf->add_object( run_setting-interface
      )->set_package( run_setting-package
      )->create_form_specification( ).

    specification->set_short_description( |{ run_setting-description } ({ TEXT-001 })| ).
  ENDMETHOD.


  METHOD genarate_class.
    IF run_setting-class IS INITIAL.
      RETURN.
    ENDIF.

    DATA(specification) = operation->for-clas->add_object( run_setting-class
      )->set_package( run_setting-package
      )->create_form_specification( ).

    specification->set_short_description( |{ run_setting-description } ({ TEXT-002 })| ).

    specification->definition->set_create_visibility( xco_cp_abap_objects=>visibility->private ).
    specification->definition->set_global_friends( VALUE #( ( run_setting-factory ) ) ).
    specification->definition->add_interface( run_setting-interface ).
  ENDMETHOD.


  METHOD genarate_factory.
    DATA method_name    TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name.
    DATA method_content TYPE string.

    IF run_setting-factory IS INITIAL.
      RETURN.
    ENDIF.

    DATA(specification) = operation->for-clas->add_object( run_setting-factory
      )->set_package( run_setting-package
      )->create_form_specification( ).

    specification->set_short_description( |{ run_setting-description } ({ TEXT-004 })| ).

    specification->definition->set_abstract( ).
    specification->definition->set_final( ).

    method_name = |CREATE_{ run_setting-name }|.
    DATA(method) = specification->definition->section-public->add_class_method( method_name ).
    method->add_returning_parameter( 'RESULT' )->set_type( xco_cp_abap=>interface( run_setting-interface ) ).

    IF run_setting-injector IS INITIAL.
      method_content = |RETURN NEW { run_setting-class }( ).|.
      specification->implementation->add_method( method_name )->set_source( VALUE #( ( method_content ) ) ).
    ELSE.
      add_injector_content( specification = specification
                            method_name   = method_name ).
    ENDIF.
  ENDMETHOD.


  METHOD genarate_injector.
    DATA method_name    TYPE if_xco_gen_clas_s_fo_d_section=>tv_method_name.
    DATA method_content TYPE string.

    IF run_setting-injector IS INITIAL.
      RETURN.
    ENDIF.

    DATA(specification) = operation->for-clas->add_object( run_setting-injector
      )->set_package( run_setting-package
      )->create_form_specification( ).

    specification->set_short_description( |{ run_setting-description } ({ TEXT-003 })| ).

    specification->definition->set_abstract( ).
    specification->definition->set_final( ).
    specification->definition->set_for_testing( ).

    method_name = |INJECT_{ run_setting-name }|.
    DATA(method) = specification->definition->section-public->add_class_method( method_name ).
    method->add_importing_parameter( 'DOUBLE' )->set_type( xco_cp_abap=>interface( run_setting-interface ) ).

    method_content = |{ run_setting-factory }=>{ run_setting-name } = double.|.
    specification->implementation->add_method( method_name )->set_source( VALUE #( ( method_content ) ) ).
  ENDMETHOD.


  METHOD add_injector_content.
    DATA attribute_name TYPE sxco_ao_component_name.

    specification->definition->set_global_friends( VALUE #( ( run_setting-injector ) ) ).

    attribute_name = CONV #( run_setting-name ).
    specification->definition->section-private->add_class_data( attribute_name )->set_type(
        xco_cp_abap=>interface( run_setting-interface ) ).

    specification->implementation->add_method( method_name )->set_source( VALUE #(
                                                                              ( |IF { attribute_name } IS BOUND.| )
                                                                              ( |RETURN { attribute_name }.| )
                                                                              ( `ELSE.` )
                                                                              ( |RETURN NEW { run_setting-class }( ).| )
                                                                              ( `ENDIF.` ) ) ).
  ENDMETHOD.
ENDCLASS.
