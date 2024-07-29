Client Guide
============

Table of Contents
-----------------

1. `Introduction <#introduction>`__
2. `Installation <#installation>`__
3. `Usage <#usage>`__
4. `Functions <#functions>`__
5. `Payment <#payment>`__

Introduction
------------

The client is the interface for end users to submit task requests for
hosts to compute and return the results. This guide will walk you
through the process of setting up and using the client CLI.

Installation
------------

1. To install the client, you will need to have Docker installed on your
   machine. You can download Docker from the `official Docker
   website <https://www.docker.com/get-started>`__.
2. Start and serve the client container. (see pymeca-actors readme)

Usage
-----

The client CLI will look like this:

::

   PS > docker run -it --rm -v $PWD/build:/scripts/src/build mock_actor mock_user.py
   Started user with address: 0x80deA8162bDC8B4b540f41871dacf0b7C2aBF0CD

   0. finish_task
   1. send_task_on_blockchain
   2. get_tasks
   3. get_towers_hosts_for_task
   x. Exit
   Enter action: 

You can check tasks available and their hosts and towers. Then submit a
task with the chosen combination. An example of submit task looks like
this:

::

   ...
   0. finish_task
   1. send_task_on_blockchain
   2. get_tasks
   3. get_towers_hosts_for_task
   x. Exit
   Enter action: 1

   Running send_task_on_blockchain
   Enter ipfs_sha256: 0xd8472b26471ec453b45fb9ceac8242e147f70850d859ce8f494f6d25923530ff
   Enter host_address: 0x5aad26e6aDc5ade3f7FBD70faEB5A3598414DD2C
   Enter tower_address: 0x063E67c13622B6d2E07C1cE175d66bF35F5ad595
   Enter input_hash: {"prompt": "cute cat 4k, high-res, masterpiece, best quality, soft lighting, dynamic angle",    "num_inference_steps": 6}

   Enter use_sgx: -

Results will be stored in $PWD/build if saved, or displayed on the CLI.

Functions
---------
https://sbip-sg.github.io/pymeca/autoapi/pymeca/user/index.html

Payment
-------

Payment for blockchain transactions and fees are done using the account
associated with the private key in the environment variables.
