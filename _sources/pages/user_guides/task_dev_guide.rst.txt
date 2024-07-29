Task Developer Guide
====================

Table of Contents
-----------------

1. `Introduction <#introduction>`__
2. `Installation <#installation>`__
3. `Usage <#usage>`__
4. `Functions <#functions>`__
5. `Payment <#payment>`__

Introduction
------------

The task developer is responsible for creating tasks that can be
executed by hosts. This guide will walk you through the process of
setting up and managing a task developer using the CLI. To see how to
develop tasks, check out :ref:`example-tasks`.

Installation
------------

1. To install the task developer, you will need to have Docker installed
   on your machine. You can download Docker from the `official Docker
   website <https://www.docker.com/get-started>`__.
2. Start and serve the task developer container. (see `pymeca-actors
   readme <https://github.com/sbip-sg/meca/blob/main/pymeca-actors/README.md>`__)
3. Ensure that you have a valid connection to IPFS for uploading. (see
   `IPFS installation docs <https://docs.ipfs.tech/install/>`__) You can also use the docker image
   from IPFS following instructions in pymeca-actors readme.

Usage
-----

The task developer CLI will look like this:

::

   PS > docker run -it --rm -v <ABSOLUTE_PATH_TO_FOLDER>:/build mock_actor mock_task_dev.py
   Started task dev with address: 0x9165625649F7aa71F2afEd65BC367d8b6bCdA025

   0. delete_task
   1. get_my_tasks
   2. register_task
   3. register_task_cid
   4. update_task_fee
   5. update_task_owner
   6. update_task_size
   7. get_sha256_from_cid
   8. add_folder_to_ipfs
   x. Exit
   Enter action:

The CLI provides options to manage your tasks. ``add_folder_to_ipfs`` to
upload a local folder to the IPFS node specified in the env variables.
Then ``register_task`` using the IPFS CID.

Functions
---------
https://sbip-sg.github.io/pymeca/autoapi/pymeca/task/index.html

Additional non-util functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   - add_folder_to_ipfs(folder_path: str) -> str:
      Adds a local folder on your host machine to IPFS. 
      
      Parameters: 
         folder_path: ``/build/<folder_name_on_local_device>``.
      Returns:
         The result of adding a folder on IPFS, which is the metadata of each file in the folder and the folder itself.
         You can then get the CID of the folder from the hash field of the metadata of the folder.

Payment
-------

Payment for blockchain transactions and fees are done using the account
associated with the private key in the environment variables.
