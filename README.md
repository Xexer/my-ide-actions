# [MIA] My IDE Actions
Since release 2502, there have been IDE Actions in the ABAP Environment. This makes it possible to write your own actions in the ABAP Development Tools. In this repository you will find a collection of different actions.

## Installation

Currently, IDE Actions cannot be saved in Git, so the IDE Actions must first be created after installation. Here you will find all steps to create them.

### Create class

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
| IDE Action Name              | Z_MIA_NEW_CLASS                                                                                             |
| Title                        | Migrate SELECT statement                                                                                    |
| Summary                      | Migrates an Open SQL statement to ABAP SQL in the new notation and replaces tables with Core Data Services. |
| Implementing Class           | ZCL_MIA_SELECTCONVERT_ACTION                                                                                |
| Input UI Configuration Class |                                                                                                             |
| Number of Focused Resources  | One                                                                                                         |
| Object Type (Filter)         | CLAS                                                                                                        |


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

## Public Material

- Software-Heroes: [ADT - My IDE Actions](https://software-heroes.com/en/blog/tools-adt-my-ide-actions-en)
- SAP Community: [[MIA] My IDE Actions](https://community.sap.com/t5/technology-blogs-by-members/mia-my-ide-actions/ba-p/14019000)