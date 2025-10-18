CLASS zcl_mia_object_generator DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_mia_object_generator.

  PRIVATE SECTION.
    "! Actual run settings for creation process
    DATA run_setting      TYPE zif_mia_object_generator=>setting.

    "! Factory was found and should be extended
    DATA add_to_factory   TYPE abap_boolean.

    "! Injector was found and should be extended
    DATA add_to_injector  TYPE abap_boolean.

    "! Mode for object activation
    DATA activate_objects TYPE abap_boolean VALUE abap_true.

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

    "! Extend the Factory
    "! @parameter operation | XCO Operation
    METHODS extend_factory
      IMPORTING operation TYPE REF TO if_xco_cp_gen_clas_d_o_patch.

    "! Extend the Injector
    "! @parameter operation | XCO Operation
    METHODS extend_injector
      IMPORTING operation TYPE REF TO if_xco_cp_gen_clas_d_o_patch.

    "! Validate the configuration
    "! @parameter result | Messages
    METHODS validate_configuration
      RETURNING VALUE(result) TYPE sxco_t_messages.

    "! Check if the objects should be added to factory and injector
    METHODS set_additional_settings.

    "! Extend the logic for the injector
    "! @parameter object      | Factory class object
    "! @parameter method_name | Name of the method
    METHODS extend_injector_content
      IMPORTING !object     TYPE REF TO if_xco_cp_gen_clas_d_o_pat_obj
                method_name TYPE sxco_ao_component_name.

ENDCLASS.


CLASS zcl_mia_object_generator IMPLEMENTATION.
  METHOD zif_mia_object_generator~generate_objects_via_setting.
    run_setting = setting.

    result-messages = validate_configuration( ).
    IF result-messages IS NOT INITIAL.
      result-success = abap_false.
      RETURN.
    ENDIF.

    set_additional_settings( ).

    DATA(put_operation) = xco_cp_generation=>environment->dev_system( run_setting-transport )->create_put_operation( ).
    DATA(patch_operation) = xco_cp_generation=>environment->dev_system( run_setting-transport )->for-clas->create_patch_operation( ).

    genarate_class( put_operation ).
    generate_interface( put_operation ).

    IF add_to_factory = abap_true.
      extend_factory( patch_operation ).
    ELSE.
      genarate_factory( put_operation ).
    ENDIF.

    IF add_to_injector = abap_true.
      extend_injector( patch_operation ).
    ELSE.
      genarate_injector( put_operation ).
    ENDIF.

    IF activate_objects = abap_true.
      DATA(operation_result) = put_operation->execute( ).
      DATA(operation_patch_result) = patch_operation->execute( ).
    ELSE.
      operation_result = put_operation->execute( VALUE #( ( xco_cp_generation=>put_operation_option->skip_activation ) ) ).
      operation_patch_result = patch_operation->execute( ).
    ENDIF.

    result = CORRESPONDING #( run_setting ).
    result-findings       = operation_result->findings.
    result-findings_patch = operation_patch_result->findings.

    IF result-findings->contain_errors( ) OR result-findings_patch->contain_errors( ).
      result-success = abap_false.
    ELSE.
      result-success = abap_true.
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

    IF run_setting-interface IS NOT INITIAL.
      specification->definition->add_interface( run_setting-interface ).
    ENDIF.

    IF run_setting-factory IS NOT INITIAL.
      specification->definition->set_global_friends( VALUE #( ( run_setting-factory ) ) ).
    ENDIF.
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

    method_name = |CREATE_{ run_setting-inst_name }|.
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

    method_name = |INJECT_{ run_setting-inst_name }|.
    DATA(method) = specification->definition->section-public->add_class_method( method_name ).
    method->add_importing_parameter( 'DOUBLE' )->set_type( xco_cp_abap=>interface( run_setting-interface ) ).

    method_content = |{ run_setting-factory }=>double_{ run_setting-inst_name } = double.|.
    specification->implementation->add_method( method_name )->set_source( VALUE #( ( method_content ) ) ).
  ENDMETHOD.


  METHOD add_injector_content.
    specification->definition->set_global_friends( VALUE #( ( run_setting-injector ) ) ).

    specification->definition->section-private->add_class_data( |double_{ run_setting-inst_name }| )->set_type(
        xco_cp_abap=>interface( run_setting-interface ) ).

    specification->implementation->add_method( method_name )->set_source(
        VALUE #( ( |IF double_{ run_setting-inst_name } IS BOUND.| )
                 ( |  RETURN double_{ run_setting-inst_name }.| )
                 ( `ELSE.` )
                 ( |  RETURN NEW { run_setting-class }( ).| )
                 ( `ENDIF.` ) ) ).
  ENDMETHOD.


  METHOD extend_injector_content.
    object->for-insert->definition->section-private->add_class_data( |double_{ run_setting-inst_name }| )->set_type(
        xco_cp_abap=>interface( run_setting-interface ) ).

    object->for-insert->implementation->add_method( CONV #( method_name ) )->set_source(
        VALUE #( ( |IF double_{ run_setting-inst_name } IS BOUND.| )
                 ( |  RETURN double_{ run_setting-inst_name }.| )
                 ( `ELSE.` )
                 ( |  RETURN NEW { run_setting-class }( ).| )
                 ( `ENDIF.` ) ) ).
  ENDMETHOD.


  METHOD validate_configuration.
    DATA dummy TYPE string ##NEEDED.

    IF run_setting-transport IS INITIAL.
      MESSAGE e001(z_mia_core) INTO dummy.
      INSERT xco_cp=>sy->message( ) INTO TABLE result.
    ENDIF.

    IF run_setting-package IS INITIAL.
      MESSAGE e002(z_mia_core) INTO dummy.
      INSERT xco_cp=>sy->message( ) INTO TABLE result.
    ENDIF.

    IF run_setting-prefix IS INITIAL.
      MESSAGE e003(z_mia_core) INTO dummy.
      INSERT xco_cp=>sy->message( ) INTO TABLE result.
    ENDIF.

    IF run_setting-description IS INITIAL.
      MESSAGE e004(z_mia_core) INTO dummy.
      INSERT xco_cp=>sy->message( ) INTO TABLE result.
    ENDIF.

    IF run_setting-class IS INITIAL.
      MESSAGE e005(z_mia_core) INTO dummy.
      INSERT xco_cp=>sy->message( ) INTO TABLE result.
    ENDIF.

    IF run_setting-interface IS INITIAL AND ( run_setting-factory IS NOT INITIAL OR run_setting-injector IS NOT INITIAL ).
      MESSAGE e006(z_mia_core) INTO dummy.
      INSERT xco_cp=>sy->message( ) INTO TABLE result.
    ENDIF.

    IF run_setting-factory IS INITIAL AND run_setting-injector IS NOT INITIAL.
      MESSAGE e007(z_mia_core) INTO dummy.
      INSERT xco_cp=>sy->message( ) INTO TABLE result.
    ENDIF.

    IF run_setting-class IS NOT INITIAL AND xco_cp_abap=>class( run_setting-class )->exists( ).
      MESSAGE e008(z_mia_core) WITH run_setting-class INTO dummy.
      INSERT xco_cp=>sy->message( ) INTO TABLE result.
    ENDIF.

    IF run_setting-interface IS NOT INITIAL AND xco_cp_abap=>interface( run_setting-interface )->exists( ).
      MESSAGE e009(z_mia_core) WITH run_setting-interface INTO dummy.
      INSERT xco_cp=>sy->message( ) INTO TABLE result.
    ENDIF.
  ENDMETHOD.


  METHOD set_additional_settings.
    DATA(factory) = xco_cp_abap=>class( run_setting-factory ).
    IF factory->exists( ).
      add_to_factory = abap_true.
    ENDIF.

    DATA(injector) = xco_cp_abap=>class( run_setting-injector ).
    IF injector->exists( ).
      add_to_injector = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD extend_factory.
    DATA method_name    TYPE sxco_ao_component_name.
    DATA method_content TYPE string.

    IF run_setting-factory IS INITIAL.
      RETURN.
    ENDIF.

    DATA(factory_object) = operation->add_object( run_setting-factory ).

    method_name = |CREATE_{ run_setting-inst_name }|.
    DATA(method) = factory_object->for-insert->definition->section-public->add_class_method( method_name ).
    method->add_returning_parameter( 'RESULT' )->set_type( xco_cp_abap=>interface( run_setting-interface ) ).

    IF run_setting-injector IS INITIAL.
      method_content = |RETURN NEW { run_setting-class }( ).|.
      factory_object->for-insert->implementation->add_method( CONV #( method_name ) )->set_source(
          VALUE #( ( method_content ) ) ).
    ELSE.
      extend_injector_content( object      = factory_object
                               method_name = method_name ).
    ENDIF.
  ENDMETHOD.


  METHOD extend_injector.
    DATA method_name    TYPE sxco_ao_component_name.
    DATA method_content TYPE string.

    IF run_setting-injector IS INITIAL.
      RETURN.
    ENDIF.

    DATA(injector_object) = operation->add_object( run_setting-injector ).

    method_name = |INJECT_{ run_setting-inst_name }|.
    DATA(method) = injector_object->for-insert->definition->section-public->add_class_method( method_name ).
    method->add_importing_parameter( 'DOUBLE' )->set_type( xco_cp_abap=>interface( run_setting-interface ) ).

    method_content = |{ run_setting-factory }=>double_{ run_setting-inst_name } = double.|.
    injector_object->for-insert->implementation->add_method( CONV #( method_name ) )->set_source(
        VALUE #( ( method_content ) ) ).
  ENDMETHOD.
ENDCLASS.
