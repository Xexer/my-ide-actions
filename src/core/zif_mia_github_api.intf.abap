INTERFACE zif_mia_github_api
  PUBLIC.

  CONSTANTS github_raw TYPE string VALUE `https://raw.githubusercontent.com`.

  "! Load RAW file from GitHub
  "! @parameter path   | Path to to raw file
  "! @parameter result | Content of the file
  METHODS load_raw_file
    IMPORTING !path         TYPE string
    RETURNING VALUE(result) TYPE string.
ENDINTERFACE.
