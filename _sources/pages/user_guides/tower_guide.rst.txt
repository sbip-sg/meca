Tower Guide
===========

Table of Contents
-----------------

1. `Introduction <#introduction>`__
2. `Installation <#installation>`__
3. `Usage <#usage>`__
4. `Functions <#functions>`__
5. `Payment <#payment>`__

Introduction
------------

The tower serves as a relay point on the edge for tasks to be sent to
and from clients and hosts. It is a critical component of the MEC
Anywhere ecosystem as it ensures security and privacy for end users.
This guide will walk you through the process of setting up and managing
a tower.

Installation
------------

1. To install the tower, you will need to have Docker installed on your
   machine. You can download Docker from the `official Docker
   website <https://www.docker.com/get-started>`__.
2. Start and serve the tower-server container.

-  Configure the blockchain endpoint in the ``config.json`` file.

3. Register the tower using our CLI template actor for towers (different
   from tower-server). (see pymeca-actors readme)

Usage
-----

The tower CLI will look like this:

::

   PS > docker run -it --rm mock_actor_intern mock_tower.py
   Started tower with address: 0x063E67c13622B6d2E07C1cE175d66bF35F5ad595

   Tower is not registered. Registering...
   Enter size limit: (10000)
   Enter public connection: (http://172.17.0.1:7777)
   Enter fee: (10)
   Enter fee type: (0)
   Enter initial deposit: (100)
   Tower registered.

   0. accept_host
   1. delete_host
   2. delete_tower
   3. get_my_hosts
   4. get_pending_hosts
   5. is_registered
   6. register_tower
   7. reject_host
   8. update_fee
   9. update_tower_public_connection
   10. update_tower_size_limit
   x. Exit
   Enter action: 

The CLI will prompt you to enter the necessary information to register
the tower if not yet done so. Then there are options to manage hosts
registered with the tower. A task will be relayed through the
tower-server automatically when a client submits a task to a host
registered with the tower. When a host registers with the tower, the
tower will have to accept it before the host can start receiving tasks.

Functions
---------
https://sbip-sg.github.io/pymeca/autoapi/pymeca/tower/index.html

Payment
-------

Payment for blockchain transactions and fees are done using the account
associated with the private key in the environment variables.
