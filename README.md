# OCI Streams as Code

This is a tiny project to try out OCI Streams, using IaC with Terraform and consuming the streams with a python client, also using a kafka-connect.

> Stacks:

- [x] Kafka<br>
- [x] Python Kafka Library<br>
- [x] OCI Streams<br>
- [x] Terraform<br>
- [x] Docker<br>
- [x] Docker Compose<br>
- [x] Kafka Connect<br>

## Instructions

- Infrastructure

  - Copy your private key (.pem format) from your OCI account into a file called `private_key.pem` inside etc/deployment;

  - Create the file `terraform.tfvars` inside etc/deployment with the required variables, for example;

  ```hcl
  tenancy_ocid         = ""
  user_ocid            = ""
  user_key_fingerprint = ""
  tags                 = { "ENVIRONMENT" = "DEV", "MANAGED_BY" = "Terraform" }
  ```

  - Use the Makefile to create the infrastructure:

  ```bash
  make deploy
  ```

- Kafka Connect

  - Use the Makefile to run the kafka connect:

  ```bash
  make run-kafka-connect
  ```

- Insert Random Data

  - Use the Makefile to run to insert random data:

  ```bash
  make run-mysql-insert-data
  ```

- Consumer Client

  - Use the Makefile to run the consumer client:

  ```bash
  make run-consumer-client
  ```

- Clean up

  - Use the Makefile to up the clean the resources from OCI and local containers:

  ```bash
  make destroy
  ```
