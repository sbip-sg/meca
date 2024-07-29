Host Guide
==========

Table of Contents
-----------------

1. `Introduction <#introduction>`__
2. `Installation <#installation>`__
3. `Usage <#usage>`__
4. `Functions <#functions>`__
5. `Payment <#payment>`__

Introduction
------------

The host is the service that executes tasks submitted by clients. This
guide will walk you through the process of setting up and managing a
host using the CLI. You can also check out the `MECA Desktop
application <https://github.com/sbip-sg/meca_desktop>`__ for a
more user-friendly experience.

Installation
------------

1. To install the host, you will need to have Docker installed on your
   machine. You can download Docker from the `official Docker
   website <https://www.docker.com/get-started>`__.
2. Start and serve the host container. (see pymeca-actors readme)
3. Build the `task
   executor <https://github.com/sbip-sg/meca_desktop/tree/main/task_executor>`__.
4. Ensure that you have a valid connection to IPFS for retrieval (see
   https://docs.ipfs.tech/quickstart/retrieve/#ipfs-retrieval-methods).

Usage
-----

The host CLI will look like this:

::

   PS > docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock mock_actor mock_host.py
   Started host with address: 0x5aad26e6aDc5ade3f7FBD70faEB5A3598414DD2C

   Host is not registered. Registering...
   Enter block timeout limit: (10)
   Enter public key: (0xefb690cea3ef14b607f1b5d49b4112f77c604fa3ff38a1ff05e13a6214e4c199346da45151ce3d59827f7d14b5ae24baa95fd349c6cfa0457ec83454fca6f846) 
   Enter initial deposit: (100) 
   Host registered.

   0. _bytes_from_hex_public_key
   1. add_task
   2. delete_task
   3. get_my_tasks
   4. get_my_towers
   5. get_task_block_timeout    
   6. get_task_fee
   7. increase_stake
   8. is_registered
   9. register
   10. register_for_tower
   11. register_task_output
   12. unregister
   13. update_block_timeout_limit
   14. update_public_key
   15. update_task_block_timeout
   16. update_task_fee
   17. wrong_input_hash
   18. wait_for_my_task
   19. get_tasks
   20. get_towers
   x. Exit
   Enter action:

The CLI will prompt you to enter the necessary information to register
the host if not yet done so. Then there are options to manage tasks and
towers registered with the host. A task will be relayed through the
tower-server automatically when a client submits a task to a host
registered with the tower.

When a host registers with the tower, the tower will have to accept it
before the host can start receiving tasks.

The host can only receive tasks that have been added. ``get_tasks`` to
see tasks made available by task developers.

Finally, ``wait_for_my_task`` to start receiving and processing tasks,
which will be started and computed by the task executor which uses
Docker.

Functions
---------
https://sbip-sg.github.io/pymeca/autoapi/pymeca/host/index.html

Additional non-util functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   - wait_for_my_task(tower_address: str) -> None
      Sets up a threaded websocket connection to the given tower to receive tasks.
      
      Parameters: 
         tower_address - The address of the tower to connect to. Host must be registered with the tower.
      
      Returns: None if the connection was successful.

Payment
-------

Payment for blockchain transactions and fees are done using the account
associated with the private key in the environment variables.
