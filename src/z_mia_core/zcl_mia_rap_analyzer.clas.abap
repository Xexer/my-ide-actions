CLASS zcl_mia_rap_analyzer DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_mia_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_mia_rap_analyzer.

    METHODS constructor
      IMPORTING service_name TYPE string.

  PRIVATE SECTION.
    "! Name of the service binding
    DATA service_name TYPE string.

    "! Temp. stack for all objects
    DATA object_stack TYPE zif_mia_rap_analyzer=>entities.

    "! Used entities for assembling
    DATA used_entites TYPE string_table.

    "! Creates the RAP object from the object stack
    "! @parameter result | RAP Object
    METHODS assemble_object
      RETURNING VALUE(result) TYPE zif_mia_rap_analyzer=>rap_object.

    "! Analyze the service binding object
    "! @parameter name   | Name of the object
    "! @parameter parent | Parent of the object
    "! @parameter alias  | Alias for the object
    METHODS analyze_service_binding
      IMPORTING !name   TYPE string
                !parent TYPE string OPTIONAL
                !alias  TYPE string OPTIONAL.

    "! Analyze the service definition object
    "! @parameter name   | Name of the object
    "! @parameter parent | Parent of the object
    "! @parameter alias  | Alias for the object
    METHODS analyze_service_definition
      IMPORTING !name   TYPE string
                !parent TYPE string OPTIONAL
                !alias  TYPE string OPTIONAL.

    "! Analyze the Core Data Service object
    "! @parameter name   | Name of the object
    "! @parameter parent | Parent of the object
    "! @parameter alias  | Alias for the object
    METHODS analyze_cds
      IMPORTING !name   TYPE string
                !parent TYPE string OPTIONAL
                !alias  TYPE string OPTIONAL.

    "! Analyze the table object
    "! @parameter name   | Name of the object
    "! @parameter parent | Parent of the object
    "! @parameter alias  | Alias for the object
    METHODS analyze_table
      IMPORTING !name   TYPE string
                !parent TYPE string OPTIONAL
                !alias  TYPE string OPTIONAL.

    "! Analyze the Metadata object
    "! @parameter name   | Name of the object
    "! @parameter parent | Parent of the object
    "! @parameter alias  | Alias for the object
    METHODS analyze_metadata
      IMPORTING !name   TYPE string
                !parent TYPE string OPTIONAL
                !alias  TYPE string OPTIONAL.

    "! Analyze the Behavior object
    "! @parameter name   | Name of the object
    "! @parameter parent | Parent of the object
    "! @parameter alias  | Alias for the object
    METHODS analyze_behavior
      IMPORTING !name   TYPE string
                !parent TYPE string OPTIONAL
                !alias  TYPE string OPTIONAL.

    "! Analyze the table object
    "! @parameter name   | Name of the object
    "! @parameter parent | Parent of the object
    "! @parameter alias  | Alias for the object
    METHODS analyze_domain
      IMPORTING !name   TYPE string
                !parent TYPE string OPTIONAL
                !alias  TYPE string OPTIONAL.

    "! Add the nodes as hierarchy
    "! @parameter actual_object | Actual node
    "! @parameter childs        | Actual child nodes
    METHODS add_hierarchy_level
      IMPORTING actual_object TYPE string
      CHANGING  childs        TYPE zif_mia_rap_analyzer=>rap_childs.

    METHODS fill_parent_connection
      IMPORTING rap_object    TYPE zif_mia_rap_analyzer=>rap_object
      RETURNING VALUE(result) TYPE zif_mia_rap_analyzer=>rap_object.
ENDCLASS.


CLASS zcl_mia_rap_analyzer IMPLEMENTATION.
  METHOD constructor.
    me->service_name = service_name.
  ENDMETHOD.


  METHOD zif_mia_rap_analyzer~get_objects_in_stack.
    CLEAR object_stack.
    analyze_service_binding( service_name ).

    DELETE object_stack WHERE not_found = abap_true.

    LOOP AT object_stack REFERENCE INTO DATA(stack).
      stack->name   = to_upper( stack->name ).
      stack->parent = to_upper( stack->parent ).
    ENDLOOP.

    RETURN object_stack.
  ENDMETHOD.


  METHOD zif_mia_rap_analyzer~get_rap_object.
    zif_mia_rap_analyzer~get_objects_in_stack( ).
    RETURN assemble_object( ).
  ENDMETHOD.


  METHOD analyze_service_binding.
    IF name IS INITIAL.
      RETURN.
    ENDIF.

    INSERT VALUE #( name   = name
                    type   = zif_mia_rap_analyzer=>types-service_binding
                    alias  = alias
                    parent = parent ) INTO TABLE object_stack REFERENCE INTO DATA(entry).

    DATA(service_binding) = xco_cp_abap_repository=>object->srvb->for( name ).
    IF NOT service_binding->exists( ).
      entry->not_found = abap_true.
      RETURN.
    ENDIF.

    entry->package = service_binding->get_package( )->name.

    DATA(content) = service_binding->content( ).
    entry->description = content->get_short_description( ).

    LOOP AT service_binding->services->all->get( ) INTO DATA(service).
      analyze_service_definition( name   = CONV #( service->name )
                                  parent = name ).
    ENDLOOP.

    entry->loaded = abap_true.
  ENDMETHOD.


  METHOD analyze_service_definition.
    IF name IS INITIAL.
      RETURN.
    ENDIF.

    INSERT VALUE #( name   = name
                    type   = zif_mia_rap_analyzer=>types-service_definition
                    alias  = alias
                    parent = parent ) INTO TABLE object_stack REFERENCE INTO DATA(entry).

    DATA(service_definition) = xco_cp_abap_repository=>object->srvd->for( CONV #( name ) ).
    IF NOT service_definition->exists( ).
      entry->not_found = abap_true.
      RETURN.
    ENDIF.

    entry->package = service_definition->get_package( )->name.

    DATA(content) = service_definition->content( ).
    entry->description = content->get_short_description( ).

    LOOP AT service_definition->exposures->all->get( ) INTO DATA(exposure).
      IF exposure->content( )->get_cds_entity( )->get_data_definition( )->view_entity( )->content( )->get_root_indicator( ) = abap_false.
        CONTINUE.
      ENDIF.

      analyze_cds( name   = CONV #( exposure->cds_entity )
                   parent = name
                   alias  = exposure->content( )->get_alias( ) ).
    ENDLOOP.

    entry->loaded = abap_true.
  ENDMETHOD.


  METHOD analyze_cds.
    IF name IS INITIAL.
      RETURN.
    ENDIF.

    INSERT VALUE #( name   = name
                    type   = zif_mia_rap_analyzer=>types-cds
                    alias  = alias
                    parent = parent ) INTO TABLE object_stack REFERENCE INTO DATA(entry).

    DATA(cds) = xco_cp_cds=>view_entity( CONV #( name ) ).
    IF NOT cds->exists( ).
      DATA(table) = xco_cp_abap_dictionary=>database_table( CONV #( name ) ).
      IF table->exists( ).
        DELETE object_stack WHERE name = name.
        analyze_table( name   = name
                       parent = parent ).
        RETURN.
      ENDIF.

      entry->not_found = abap_true.
      RETURN.
    ENDIF.

    DATA(content) = cds->content( ).
    entry->description = content->get_short_description( ).
    entry->root        = content->get_root_indicator( ).

    DATA(source) = content->get_data_source( ).
    entry->alias = source-alias.

    IF source-view_entity IS NOT INITIAL.
      analyze_cds( name   = CONV #( source-view_entity )
                   parent = entry->name ).
    ENDIF.

    LOOP AT cds->compositions->all->get( ) INTO DATA(composition).
      analyze_cds( name   = CONV #( composition->target )
                   parent = name
                   alias  = composition->content( )->get_alias( ) ).
    ENDLOOP.

    analyze_metadata( name   = entry->name
                      parent = entry->name ).

    IF entry->root = abap_true.
      analyze_behavior( name   = entry->name
                        parent = entry->name ).
    ENDIF.

    entry->loaded = abap_true.
  ENDMETHOD.


  METHOD analyze_table.
    IF name IS INITIAL.
      RETURN.
    ENDIF.

    INSERT VALUE #( name   = name
                    type   = zif_mia_rap_analyzer=>types-table
                    alias  = alias
                    parent = parent ) INTO TABLE object_stack REFERENCE INTO DATA(entry).

    DATA(table) = xco_cp_abap_dictionary=>database_table( CONV #( name ) ).
    IF NOT table->exists( ).
      entry->not_found = abap_true.
      RETURN.
    ENDIF.

    DATA(content) = table->content( ).
    entry->database    = to_upper( name ).
    entry->description = content->get_short_description( ).

    LOOP AT table->fields->all->get( ) INTO DATA(field).
      TRY.
          DATA(domain) = field->content( )->get_type( )->get_data_element( )->content( )->get_data_type( )->get_domain( ).
          analyze_domain( name   = CONV #( domain->name )
                          parent = name ).

        CATCH cx_sy_ref_is_initial.
          CONTINUE.
      ENDTRY.
    ENDLOOP.

    entry->loaded = abap_true.
  ENDMETHOD.


  METHOD analyze_metadata.
    INSERT VALUE #( name   = name
                    type   = zif_mia_rap_analyzer=>types-metadata
                    alias  = alias
                    parent = parent ) INTO TABLE object_stack REFERENCE INTO DATA(entry).

    DATA(metadata) = xco_cp_abap_repository=>object->ddlx->for( name ).
    IF NOT metadata->exists( ).
      entry->not_found = abap_true.
      RETURN.
    ENDIF.

    entry->loaded = abap_true.
  ENDMETHOD.


  METHOD analyze_behavior.
    INSERT VALUE #( name   = name
                    type   = zif_mia_rap_analyzer=>types-behavior
                    alias  = alias
                    parent = parent ) INTO TABLE object_stack REFERENCE INTO DATA(entry).

    DATA(behavior) = xco_cp_abap_repository=>object->bdef->for( CONV #( name ) ).
    IF NOT behavior->exists( ).
      entry->not_found = abap_true.
      RETURN.
    ENDIF.

    DATA(content) = behavior->content( ).
    entry->description = content->get_short_description( ).

    entry->loaded      = abap_true.
  ENDMETHOD.


  METHOD assemble_object.
    CLEAR used_entites.
    DATA(position) = 0.

    LOOP AT object_stack INTO DATA(object) STEP -1 WHERE root = abap_true.
      CASE position.
        WHEN 0.
          DATA(rap_layer) = REF #( result-base ).
        WHEN 1.
          rap_layer = REF #( result-consumption ).
        WHEN OTHERS.
          EXIT.
      ENDCASE.

      INSERT object-name INTO TABLE used_entites.
      rap_layer->cds_entity = object-name.

      TRY.
          rap_layer->table = object_stack[ type   = zif_mia_rap_analyzer=>types-table
                                           parent = object-name ]-database.
        CATCH cx_sy_itab_line_not_found.
          CLEAR rap_layer->table.
      ENDTRY.

      TRY.
          rap_layer->behavior = object_stack[ type   = zif_mia_rap_analyzer=>types-behavior
                                              parent = object-name ]-name.
        CATCH cx_sy_itab_line_not_found.
          CLEAR rap_layer->behavior.
      ENDTRY.

      TRY.
          rap_layer->metadata = object_stack[ type   = zif_mia_rap_analyzer=>types-metadata
                                              parent = object-name ]-name.
        CATCH cx_sy_itab_line_not_found.
          CLEAR rap_layer->metadata.
      ENDTRY.

      add_hierarchy_level( EXPORTING actual_object = object-name
                           CHANGING  childs        = rap_layer->childs ).

      position += 1.
    ENDLOOP.

    result = fill_parent_connection( result ).

    result-name            = result-base-behavior.
    result-classification  = zif_mia_rap_analyzer=>classifications-standard.
    result-service_binding = object_stack[ type = zif_mia_rap_analyzer=>types-service_binding ]-name.

    TRY.
        result-service_definition = object_stack[ type = zif_mia_rap_analyzer=>types-service_definition ]-name.
      CATCH cx_sy_itab_line_not_found.
        CLEAR result-service_definition.
    ENDTRY.

    LOOP AT object_stack INTO object WHERE type = zif_mia_rap_analyzer=>types-domain.
      INSERT object-name INTO TABLE result-domains.
    ENDLOOP.
  ENDMETHOD.


  METHOD add_hierarchy_level.
    LOOP AT object_stack INTO DATA(child) WHERE type = zif_mia_rap_analyzer=>types-cds AND parent = actual_object.
      IF line_exists( used_entites[ table_line = child-name ] ).
        CONTINUE.
      ENDIF.

      INSERT child-name INTO TABLE used_entites.
      INSERT VALUE #( cds_entity   = child-name
                      parent_child = actual_object ) INTO TABLE childs REFERENCE INTO DATA(rap_child).

      TRY.
          rap_child->table = object_stack[ type   = zif_mia_rap_analyzer=>types-table
                                           parent = rap_child->cds_entity ]-database.
        CATCH cx_sy_itab_line_not_found.
          CLEAR rap_child->table.
      ENDTRY.

      TRY.
          rap_child->metadata = object_stack[ type   = zif_mia_rap_analyzer=>types-metadata
                                              parent = rap_child->cds_entity ]-name.
        CATCH cx_sy_itab_line_not_found.
          CLEAR rap_child->metadata.
      ENDTRY.

      add_hierarchy_level( EXPORTING actual_object = child-name
                           CHANGING  childs        = childs ).
    ENDLOOP.
  ENDMETHOD.


  METHOD fill_parent_connection.
    result = rap_object.

    LOOP AT result-base-childs REFERENCE INTO DATA(child_node).
      LOOP AT result-consumption-childs INTO DATA(consumption).
        DATA(cds) = xco_cp_cds=>view_entity( CONV #( consumption-cds_entity ) ).

        IF cds->content( )->get_data_source( )-view_entity = child_node->cds_entity.
          child_node->parent = consumption-cds_entity.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD analyze_domain.
    IF name IS INITIAL.
      RETURN.
    ENDIF.

    DATA(domain) = xco_cp_abap_dictionary=>domain( CONV #( name ) ).
    IF NOT domain->exists( ).
      RETURN.
    ENDIF.

    IF domain->fixed_values->all->get( ) IS INITIAL.
      RETURN.
    ENDIF.

    CASE name.
      WHEN 'ABAP_BOOLEAN'.
        RETURN.
    ENDCASE.

    INSERT VALUE #( name   = name
                    type   = zif_mia_rap_analyzer=>types-domain
                    alias  = alias
                    parent = to_upper( parent )
                    loaded = abap_true ) INTO TABLE object_stack.
  ENDMETHOD.
ENDCLASS.
