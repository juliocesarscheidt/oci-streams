#!make

DOCKER_REPOSITORY?=consumer-client
DOCKER_TAG?=latest
DEPLOY_PATH?=$(PWD)/etc/deployment
ROOT_PATH?=$(PWD)
MYSQL_USER?=root
MYSQL_PASS?=
MYSQL_HOST?=mysql
MYSQL_PORT?=3306
MYSQL_DATABASE?=oci_database
STREAM_PREFIX?=kafka

fmt:
	cd $(DEPLOY_PATH) && terraform fmt -recursive -write=true

validate:
	cd $(DEPLOY_PATH) && terraform validate

init:
	cd $(DEPLOY_PATH) && terraform init
	make validate
	make plan

plan:
	cd $(DEPLOY_PATH) && terraform plan \
		-var-file=terraform.tfvars \
		-out=tfplan \
		-input=false \
		-var stream_prefix=$(STREAM_PREFIX)

apply:
	cd $(DEPLOY_PATH) && terraform apply \
		-auto-approve \
		-input=false tfplan

output:
	cd $(DEPLOY_PATH) && terraform output -json > outputs.json

	-@rm -f $(ROOT_PATH)/.env

	cd $(DEPLOY_PATH) && \
		echo "MYSQL_USER=$(MYSQL_USER)" >> $(ROOT_PATH)/.env && \
		echo "MYSQL_PASS=$(MYSQL_PASS)" >> $(ROOT_PATH)/.env && \
		echo "MYSQL_HOST=$(MYSQL_HOST)" >> $(ROOT_PATH)/.env && \
		echo "MYSQL_PORT=$(MYSQL_PORT)" >> $(ROOT_PATH)/.env && \
		echo "MYSQL_DATABASE=$(MYSQL_DATABASE)" >> $(ROOT_PATH)/.env && \
		echo "BOOTSTRAP_SERVERS=$$(terraform output bootstrap_servers)" >> $(ROOT_PATH)/.env && \
		echo "TOPIC_NAME=$$(terraform output topic_name)" >> $(ROOT_PATH)/.env && \
		echo "STREAM_USER_NAME=$$(terraform output stream_user_name)" >> $(ROOT_PATH)/.env && \
		echo "STREAM_USER_PASSWORD=$$(terraform output stream_user_password)" >> $(ROOT_PATH)/.env && \
		echo "KAFKA_CONNECT_TOPIC_CONFIG=$$(terraform output kakfa_connect_topic_config)" >> $(ROOT_PATH)/.env && \
		echo "KAFKA_CONNECT_TOPIC_OFFSET=$$(terraform output kakfa_connect_topic_offset)" >> $(ROOT_PATH)/.env && \
		echo "KAFKA_CONNECT_TOPIC_STATUS=$$(terraform output kakfa_connect_topic_status)" >> $(ROOT_PATH)/.env

deploy:
	make init
	make apply
	make output

run-consumer-client:
	docker-compose up --build -d consumer-client

run-mysql:
	docker-compose up -d mysql

run-mysql-insert-data:
	@$(eval RANDINT=$(shell python -c 'from random import randint; print(randint(1023, 65535));'))
	docker exec -it mysql sh -c "mysql -u$(MYSQL_USER) -p$(MYSQL_PASS) $(MYSQL_DATABASE) -e \"INSERT INTO users (name, email, password) VALUES ('test-$(RANDINT)', 'test-$(RANDINT)@mail.com', 'password-$(RANDINT)');\""
	docker exec -it mysql sh -c "mysql -u$(MYSQL_USER) -p$(MYSQL_PASS) $(MYSQL_DATABASE) -e \"SELECT * FROM users;\""

run-kafka-connect: run-mysql
	docker-compose up --build -d kafka-connect
	docker-compose up --build -d kafka-connect-setup

destroy:
	docker-compose stop && docker-compose rm --force
	cd $(DEPLOY_PATH) && terraform destroy \
		-auto-approve \
		-input=false
