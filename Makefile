# Variabel
WEB_DB_NAME = odoo_18
DOCKER = docker
DOCKER_COMPOSE = ${DOCKER} compose
CONTAINER_ODOO = odoo
CONTAINER_DB = odoo-postgres


# Bantuan (Help)
help:
	@echo "Available targets:"
	@echo "   start       - Start the containers"
	@echo "   stop        - Stop the containers"
	@echo "   restart     - Restart the containers"
	@echo "   console     - Odoo interactive shell"
	@echo "   psql        - PostgreSQL interactive shell"
	@echo "   logs odoo   - Show logs from Odoo container"
	@echo "   logs db     - Show logs from PostgreSQL container"


# Perintah
start:
	$(DOCKER_COMPOSE) up -d

stop:
	$(DOCKER_COMPOSE) down

restart:
	$(DOCKER_COMPOSE) restart

console:
	$(DOCKER) exec -it $(CONTAINER_ODOO) odoo shell --db_host=$(CONTAINER_DB) -d $(WEB_DB_NAME) -r $(CONTAINER_ODOO) -w $(CONTAINER_ODOO)

psql:
	$(DOCKER) exec -it $(CONTAINER_DB) psql -U $(CONTAINER_ODOO) -d $(WEB_DB_NAME)

define log_target
	@if [ "$(1)" = "odoo" ]; then \
		$(DOCKER_COMPOSE) logs -f $(CONTAINER_ODOO); \
	elif [ "$(1)" = "db" ]; then \
		$(DOCKER_COMPOSE) logs -f $(CONTAINER_DB); \
	else \
		echo "Invalid logs target. Use 'make logs odoo' or 'make logs db'."; \
	fi
endef

logs:
	$(call log_target,$(word 2,$(MAKECMDGOALS)))

# Phony targets
.PHONY: start stop restart console psql logs odoo db

