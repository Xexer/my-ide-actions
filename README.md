# [MIA] My IDE Actions
Since release 2502, there have been IDE Actions in the ABAP Environment. This makes it possible to write your own actions in the ABAP Development Tools. In this repository you will find a collection of different actions.

## Installation

Currently, IDE Actions cannot be saved in Git, so the IDE Actions must first be created after installation. Here you will find all steps to create them.

### Create new class

![Create class Action](./img/image-00.png)

| Object                       | Value                                                                                                       |
|------------------------------|-------------------------------------------------------------------------------------------------------------|
| Package                      | Z_MIA_ACTIONS                                                                                               |
| IDE Action Name              | Z_MIA_NEW_CLASS                                                                                             |
| Title                        | Create new class                                                                                            |
| Summary                      | Creates a new class with interface and optionally a factory and an injector for decoupling and testability. |
| Implementing Class           | ZCL_MIA_NEWCLASS_ACTION                                                                                     |
| Input UI Configuration Class | ZCL_MIA_NEWCLASS_INPUT                                                                                      |
| Number of Focused Resources  | One                                                                                                         |
| Object Type (Filter)         | DEVC                                                                                                        |

### SELECT Converter

![Create class Action](./img/image-02.png)

| Object                       | Value                                                                                                       |
|------------------------------|-------------------------------------------------------------------------------------------------------------|
| Package                      | Z_MIA_ACTIONS                                                                                               |
| IDE Action Name              | Z_MIA_SELECT_CONVERTER                                                                                      |
| Title                        | Migrate SELECT statement                                                                                    |
| Summary                      | Migrates an Open SQL statement to ABAP SQL in the new notation and replaces tables with Core Data Services. |
| Implementing Class           | ZCL_MIA_SELECTCONVERT_ACTION                                                                                |
| Input UI Configuration Class |                                                                                                             |
| Number of Focused Resources  | One                                                                                                         |
| Object Type (Filter)         | CLAS                                                                                                        |

### Code Snippets

![Create class Action](./img/image-04.png)

| Object                       | Value                                                                                                       |
|------------------------------|-------------------------------------------------------------------------------------------------------------|
| Package                      | Z_MIA_ACTIONS                                                                                               |
| IDE Action Name              | Z_MIA_CODE_SNIPPETS                                                                                         |
| Title                        | Generate Code Snippet                                                                                       |
| Summary                      | Choose from various code snippets and increase your development speed.                                      |
| Implementing Class           | ZCL_MIA_CODE_SNIPPET_ACTION                                                                                 |
| Input UI Configuration Class | ZCL_MIA_CODE_SNIPPET_INPUT                                                                                  |
| Number of Focused Resources  | One                                                                                                         |
| Object Type (Filter)         | BDEF; CLAS; DDLS; TABL                                                                                      |

### Scope Launchpad

![Create class Action](./img/image-05.png)

| Object                       | Value                                                                                                       |
|------------------------------|-------------------------------------------------------------------------------------------------------------|
| Package                      | Z_MIA_ACTIONS                                                                                               |
| IDE Action Name              | Z_MIA_SCOPING                                                                                               |
| Title                        | Scope Launchpad                                                                                             |
| Summary                      | Scope Launchpad Space and Page template to be available in configuration and for role assignment.           |
| Implementing Class           | ZCL_MIA_SCOPING_ACTION                                                                                      |
| Input UI Configuration Class | ZCL_MIA_SCOPING_INPUT                                                                                       |
| Number of Focused Resources  | At least One                                                                                                |
| Object Type (Filter)         | UIPG; UIST                                                                                                  |

## Features

Currently the following actions and features are included.

### Create class

Creates a class and optionally the interface, factory and injector. Activate the action on a focused package, the information of the package name and prefix are generated. If the package is assigned to a transport, this transport is also proposed.

![Create class Input](./img/image-01.png)

Interface , Factory and Injector are not mandatory, if you delete the string, the objects and dependencies are not created.


### SELECT Converter

Converts a SELECT statement from classic Open SQL to ABAP SQL and exchanges the table access and fields through Core Data Services if they are released for ABAP Cloud. The basis is the SwH tool "[ABAP Select Converter](https://software-heroes.com/en/abap-select-converter)".

![Convert statement](./img/image-03.png)

The SELECT must be marked, then the statement can be replaced.

### Code Snippets

It takes various code snippets from the [GitHub](https://github.com/Xexer/abap-code-snippets) repository and allows you to parameterize and insert them into the source code. Currently, various objects are supported.

![Code snippets](./img/image-06.png)

### Scope Launchpad

Scope the Launchpad Content as Spaces and Pages that have been created with the ABAP Development Tools. More informations about scoping in this [article](https://software-heroes.com/en/blog/btp-pages-and-spaces-adt).

## Public Material

- Software-Heroes: [ADT - My IDE Actions](https://software-heroes.com/en/blog/tools-adt-my-ide-actions-en)
- SAP Community: [[MIA] My IDE Actions](https://community.sap.com/t5/technology-blogs-by-members/mia-my-ide-actions/ba-p/14019000)
