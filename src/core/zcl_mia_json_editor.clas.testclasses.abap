CLASS ltc_json_formats DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_extraction FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltc_json_formats IMPLEMENTATION.
  METHOD test_extraction.
    DATA local TYPE string.

    local = `{` && |\r\n|  &&
            `    "text": "My text",` && |\r\n| &&
            `    "number_integer": 37,` && |\r\n| &&
            `    "number_decimal": 10.12,` && |\r\n| &&
            `    "boolean": true,` && |\r\n|  &&
            `    "array_element": [` && |\r\n| &&
            `        {` && |\r\n|  &&
            `            "text2": "A",` && |\r\n| &&
            `            "number2": 1` && |\r\n| &&
            `        },` && |\r\n|  &&
            `        {` && |\r\n|  &&
            `            "text2": "B",` && |\r\n| &&
            `            "number2": 2` && |\r\n| &&
            `        },` && |\r\n|  &&
            `        {` && |\r\n|  &&
            `            "text2": "C",` && |\r\n| &&
            `            "number2": 3` && |\r\n| &&
            `        }` && |\r\n|  &&
            `    ],` && |\r\n|  &&
            `    "array_data": [` && |\r\n| &&
            `        "A-A",` && |\r\n|  &&
            `        "A-B",` && |\r\n|  &&
            `        "B-A"` && |\r\n|  &&
            `    ],` && |\r\n|  &&
            `    "dynamic_list": {` && |\r\n| &&
            `        "AED": 12.50,` && |\r\n| &&
            `        "EUR": 5.20,` && |\r\n|  &&
            `        "USD": 9.96` && |\r\n| &&
            `    }` && |\r\n|  &&
            `}`.

    DATA(inline) = |\{\r\n| &
                   |    "text": "My text",\r\n| &
                   |    "number_integer": 37,\r\n| &
                   |    "number_decimal": 10.12,\r\n| &
                   |    "boolean": true,\r\n| &
                   |    "array_element": [\r\n| &
                   |        \{\r\n| &
                   |            "text2": "A",\r\n| &
                   |            "number2": 1\r\n| &
                   |        \},\r\n| &
                   |        \{\r\n| &
                   |            "text2": "B",\r\n| &
                   |            "number2": 2\r\n| &
                   |        \},\r\n| &
                   |        \{\r\n| &
                   |            "text2": "C",\r\n| &
                   |            "number2": 3\r\n| &
                   |        \}\r\n| &
                   |    ],\r\n| &
                   |    "array_data": [\r\n| &
                   |        "A-A",\r\n| &
                   |        "A-B",\r\n| &
                   |        "B-A"\r\n| &
                   |    ],\r\n| &
                   |    "dynamic_list": \{\r\n| &
                   |        "AED": 12.50,\r\n| &
                   |        "EUR": 5.20,\r\n| &
                   |        "USD": 9.96\r\n| &
                   |    \}\r\n| &
                   |\}|.

    DATA(comma) = '{' && |\r\n|  &&
                  '    "text": "My text",' && |\r\n| &&
                  '    "number_integer": 37,' && |\r\n| &&
                  '    "number_decimal": 10.12,' && |\r\n| &&
                  '    "boolean": true,' && |\r\n|  &&
                  '    "array_element": [' && |\r\n| &&
                  '        {' && |\r\n|  &&
                  '            "text2": "A",' && |\r\n| &&
                  '            "number2": 1' && |\r\n| &&
                  '        },' && |\r\n|  &&
                  '        {' && |\r\n|  &&
                  '            "text2": "B",' && |\r\n| &&
                  '            "number2": 2' && |\r\n| &&
                  '        },' && |\r\n|  &&
                  '        {' && |\r\n|  &&
                  '            "text2": "C",' && |\r\n| &&
                  '            "number2": 3' && |\r\n| &&
                  '        }' && |\r\n|  &&
                  '    ],' && |\r\n|  &&
                  '    "array_data": [' && |\r\n| &&
                  '        "A-A",' && |\r\n|  &&
                  '        "A-B",' && |\r\n|  &&
                  '        "B-A"' && |\r\n|  &&
                  '    ],' && |\r\n|  &&
                  '    "dynamic_list": {' && |\r\n| &&
                  '        "AED": 12.50,' && |\r\n| &&
                  '        "EUR": 5.20,' && |\r\n|  &&
                  '        "USD": 9.96' && |\r\n| &&
                  '    }' && |\r\n|  &&
                  '}'.

    cl_abap_unit_assert=>assert_not_initial( local ).
    cl_abap_unit_assert=>assert_not_initial( inline ).
    cl_abap_unit_assert=>assert_not_initial( comma ).
  ENDMETHOD.
ENDCLASS.
