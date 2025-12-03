CLASS ltc_code_analyzer DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zif_mia_metadata.

    METHODS get_small_metadata
      RETURNING VALUE(result) TYPE string_table.

    METHODS get_bigger_metadata
      RETURNING VALUE(result) TYPE string_table.

    METHODS setup.
    METHODS parse_small_code  FOR TESTING RAISING cx_static_check.
    METHODS parse_bigger_code FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS zcl_mia_metadata DEFINITION LOCAL FRIENDS ltc_code_analyzer.

CLASS ltc_code_analyzer IMPLEMENTATION.
  METHOD setup.
    cut = NEW zcl_mia_metadata( ).
  ENDMETHOD.


  METHOD parse_small_code.
    DATA(result) = cut->parse_source_code_to_input( core_data_service = `ZRH_I_Configuration`
                                                    code              = get_small_metadata( ) ).

    cl_abap_unit_assert=>assert_not_initial( result ).
  ENDMETHOD.


  METHOD parse_bigger_code.
    DATA(result) = cut->parse_source_code_to_input( core_data_service = `ZRH_C_ContactTP`
                                                    code              = get_bigger_metadata( ) ).

    cl_abap_unit_assert=>assert_not_initial( result ).
  ENDMETHOD.


  METHOD get_bigger_metadata.
    RETURN VALUE #(
        ( `@Metadata.layer: #CUSTOMER` )
        ( `@UI.headerInfo.typeName: 'Contact'` )
        ( `@UI.headerInfo.typeNamePlural: 'Contacts'` )
        ( `@UI.headerInfo.title.value: 'FullName'` )
        ( `@UI.headerInfo.description.value: 'ContactTypeInt'` )
        ( `@UI.headerInfo.typeImageUrl: #(ContactTypeIcon)` )
        ( `annotate entity ZRH_C_ContactTP with` )
        ( `{` )
        ( `  @UI.facet: [` )
        ( `    {` )
        ( `      id: 'idUserInfo',` )
        ( `      position: 10,` )
        ( `      type: #FIELDGROUP_REFERENCE,` )
        ( `      purpose: #HEADER,` )
        ( `      label: 'User details',` )
        ( `      targetQualifier: 'HEAD_USER'  ` )
        ( `    },` )
        ( `    {` )
        ( `      id: 'idGeneral',` )
        ( `      position: 10,` )
        ( `      type: #IDENTIFICATION_REFERENCE,` )
        ( `      label: 'General',` )
        ( `      targetQualifier: 'GENERAL'` )
        ( `    },` )
        ( `    {` )
        ( `      id: 'idCollectionDetail',` )
        ( `      position: 20,` )
        ( `      type: #COLLECTION,` )
        ( `      label: 'Details'` )
        ( `    },` )
        ( `    {` )
        ( `      id: 'idPerson',` )
        ( `      parentId: 'idCollectionDetail',` )
        ( `      position: 30,` )
        ( `      type: #FIELDGROUP_REFERENCE,` )
        ( `      label: 'Person',` )
        ( `      targetQualifier: 'PERSON'` )
        ( `    },` )
        ( `    {` )
        ( `      id: 'idAddress',` )
        ( `      parentId: 'idCollectionDetail',` )
        ( `      position: 40,` )
        ( `      type: #FIELDGROUP_REFERENCE,` )
        ( `      label: 'Address',` )
        ( `      targetQualifier: 'ADR'` )
        ( `    },` )
        ( `    {` )
        ( `      id: 'idDigitalContact',` )
        ( `      position: 50,` )
        ( `      type: #IDENTIFICATION_REFERENCE,` )
        ( `      label: 'Contact',` )
        ( `      targetQualifier: 'DIGITALCONTACT',` )
        ( `      hidden: #(isHiddenContactFacet)` )
        ( `    }      ` )
        ( `  ]` )
        ( `` )
        ( `  @UI.selectionField: [{ position: 10 }]` )
        ( `  @UI.lineItem: [{ position: 10 },` )
        ( `    { type: #FOR_ACTION, dataAction: 'createAddress', label: 'Create Address' },` )
        ( `    { type: #FOR_ACTION, dataAction: 'createCustomer', label: 'Create Customer' },` )
        ( `    { type: #FOR_ACTION, dataAction: 'createEmployee', label: 'Create Employee' }` )
        ( `  ]` )
        ( `  @UI.identification: [{ position: 10, qualifier: 'GENERAL' }]` )
        ( `  ContactId;` )
        ( `` )
        ( `  @UI.selectionField: [{ position: 20 }]` )
        ( `  @UI.lineItem: [{ position: 20 }]` )
        ( `  @UI.identification: [{ position: 20, qualifier: 'GENERAL' }]` )
        ( `  ContactTypeInt;` )
        ( `` )
        ( `  @UI.fieldGroup: [{ position: 10, qualifier: 'PERSON' }]` )
        ( `  FirstName;` )
        ( `` )
        ( `  @UI.fieldGroup: [{ position: 20, qualifier: 'PERSON' }]` )
        ( `  LastName;` )
        ( `` )
        ( `  @UI.lineItem: [{ position: 30 }]` )
        ( `  @EndUserText.label: 'Name'` )
        ( `  FullName;` )
        ( `` )
        ( `  @UI.fieldGroup: [{ position: 30, qualifier: 'PERSON', hidden: #(isHiddenBirthday) }]` )
        ( `  Birthday;` )
        ( `` )
        ( `  @UI.fieldGroup: [{ position: 10, qualifier: 'ADR' }]` )
        ( `  Street;` )
        ( `` )
        ( `  @UI.fieldGroup: [{ position: 20, qualifier: 'ADR' }]` )
        ( `  HouseNumber;` )
        ( `` )
        ( `  @UI.lineItem: [{ position: 50 }]` )
        ( `  @UI.fieldGroup: [{ position: 30, qualifier: 'ADR' }]` )
        ( `  Town;` )
        ( `` )
        ( `  @UI.fieldGroup: [{ position: 40, qualifier: 'ADR' }]` )
        ( `  ZipCode;` )
        ( `` )
        ( `  @UI.selectionField: [{ position: 30 }]` )
        ( `  @UI.lineItem: [{ position: 60 }]` )
        ( `  @UI.fieldGroup: [{ position: 50, qualifier: 'ADR' }]` )
        ( `  Country;` )
        ( `` )
        ( `  @UI.identification: [{ position: 10, qualifier: 'DIGITALCONTACT', hidden: #(isHiddenTelephone) }]` )
        ( `  Telephone;` )
        ( `` )
        ( `  @UI.identification: [{ position: 20, qualifier: 'DIGITALCONTACT', hidden: #(isHiddenEmail) }]` )
        ( `  Email;` )
        ( `` )
        ( `  @UI.fieldGroup: [{ position: 10, qualifier: 'HEAD_USER' }]` )
        ( `  LocalCreatedBy;` )
        ( `` )
        ( `  @UI.fieldGroup: [{ position: 20, qualifier: 'HEAD_USER' }]` )
        ( `  LocalLastChangedBy;` )
        ( `` )
        ( `  @UI.hidden: true` )
        ( `  LocalLastChanged;` )
        ( `` )
        ( `  @UI.hidden: true` )
        ( `  LastChanged;` )
        ( `` )
        ( `  @UI.hidden: true` )
        ( `  isHiddenBirthday;` )
        ( `  ` )
        ( `  @UI.hidden: true` )
        ( `  isHiddenContactFacet;` )
        ( `  ` )
        ( `  @UI.hidden: true` )
        ( `  isHiddenEmail;` )
        ( `  ` )
        ( `  @UI.hidden: true` )
        ( `  isHiddenTelephone;` )
        ( `}` ) ).
  ENDMETHOD.


  METHOD get_small_metadata.
    RETURN VALUE #( ( `@Metadata.layer: #CUSTOMER` )
                    ( `@UI: {` )
                    ( `  headerInfo: {` )
                    ( `    typeName: 'Config', ` )
                    ( `    typeNamePlural: 'Configs', ` )
                    ( `    title: {` )
                    ( `      type: #STANDARD, ` )
                    ( `      label: 'RH: Configuration', ` )
                    ( `      value: 'ConfigId'` )
                    ( `    }` )
                    ( `  }` )
                    ( `}` )
                    ( `annotate view ZRH_I_Configuration with` )
                    ( `{` )
                    ( `  @UI.identification: [ {` )
                    ( `    position: 1 ` )
                    ( `  } ]` )
                    ( `  @UI.lineItem: [ {` )
                    ( `    position: 1 ` )
                    ( `  } ]` )
                    ( `  @UI.facet: [ {` )
                    ( `    id: 'ZRH_I_Configuration', ` )
                    ( `    purpose: #STANDARD, ` )
                    ( `    type: #IDENTIFICATION_REFERENCE, ` )
                    ( `    label: 'RH: Configuration', ` )
                    ( `    position: 1 ` )
                    ( `  } ]` )
                    ( `  ConfigId;` )
                    ( `  ` )
                    ( `  @UI.identification: [ {` )
                    ( `    position: 2 ` )
                    ( `  } ]` )
                    ( `  @UI.lineItem: [ {` )
                    ( `    position: 2 ` )
                    ( `  } ]` )
                    ( `  Process;` )
                    ( `  ` )
                    ( `  @UI.identification: [ {` )
                    ( `    position: 3 ` )
                    ( `  } ]` )
                    ( `  @UI.lineItem: [ {` )
                    ( `    position: 3 ` )
                    ( `  } ]` )
                    ( `  Value;` )
                    ( `  ` )
                    ( `  @UI.identification: [ {` )
                    ( `    position: 4 ` )
                    ( `  } ]` )
                    ( `  @UI.lineItem: [ {` )
                    ( `    position: 4 ` )
                    ( `  } ]` )
                    ( `  @EndUserText.label: 'Value (High)'` )
                    ( `  ValueHigh;` )
                    ( `}` ) ).
  ENDMETHOD.
ENDCLASS.
