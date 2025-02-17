# [MIA] My IDE Actions
Since release 2502, there have been IDE Actions in the ABAP Environment. This makes it possible to write your own actions in the ABAP Development Tools. In this repository you will find a collection of different actions.

## Installation

Currently, IDE Actions cannot be saved in Git, so the IDE Actions must first be created after installation. Here you will find all steps to create them.

### Create class

![Create class Action](./img/image-00.png)

| Object                       | Value                                                                                                       |
|------------------------------|-------------------------------------------------------------------------------------------------------------|
| IDE Action Name              | Z_MIA_NEW_CLASS                                                                                             |
| Title                        | Create new class                                                                                            |
| Summary                      | Creates a new class with interface and optionally a factory and an injector for decoupling and testability. |
| Implementing Class           | ZCL_MIA_NEWCLASS_ACTION                                                                                     |
| Input UI Configuration Class | ZCL_MIA_NEWCLASS_INPUT                                                                                      |
| Number of Focused Resources  | One                                                                                                         |
| Object Type (Filter)         | DEVC                                                                                                        |


## Features

Currently the following actions are included:

- Create class - Creates a class and optionally the interface, factory and injector