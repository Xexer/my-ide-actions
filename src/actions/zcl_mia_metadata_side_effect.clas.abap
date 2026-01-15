CLASS zcl_mia_metadata_side_effect DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sd_determination.
ENDCLASS.


CLASS zcl_mia_metadata_side_effect IMPLEMENTATION.
  METHOD if_sd_determination~run.
    DATA input TYPE zcl_mia_metadata_input=>input.

    model->get_as_structure( IMPORTING result = input ).

    LOOP AT input-facets REFERENCE INTO DATA(facet).
      IF facet->target_qualifier = facet->old.
        CONTINUE.
      ENDIF.

      LOOP AT input-fields REFERENCE INTO DATA(field) WHERE qualifier = facet->old.
        field->qualifier = facet->target_qualifier.
      ENDLOOP.

      facet->old = facet->target_qualifier.
    ENDLOOP.

    SORT input-facets BY position ASCENDING.

    result = input.
  ENDMETHOD.
ENDCLASS.
