# =========================
# Variabel
# =========================
WEB_DB_NAME = odoo_18
DOCKER = docker
DOCKER_COMPOSE = ${DOCKER} compose
CONTAINER_ODOO = odoo
CONTAINER_DB = odoo-postgres

# =========================
# Bantuan
# =========================
help:
	@echo "Available targets:"
	@echo "   start               - Start the containers"
	@echo "   stop                - Stop the containers"
	@echo "   restart             - Restart the containers"
	@echo "   console             - Odoo interactive shell"
	@echo "   psql                - PostgreSQL interactive shell"
	@echo "   logs odoo           - Show logs from Odoo container"
	@echo "   logs db             - Show logs from PostgreSQL container"
	@echo "   addon <addon_name>  - Restart instance and upgrade addon"

# =========================
# Perintah dasar
# =========================
start:
	$(DOCKER_COMPOSE) up -d

stop:
	$(DOCKER_COMPOSE) down

restart:
	$(DOCKER_COMPOSE) restart

console:
	$(DOCKER) exec -it $(CONTAINER_ODOO) odoo shell --db_host=$(CONTAINER_DB) -d $(WEB_DB_NAME)

psql:
	$(DOCKER) exec -it $(CONTAINER_DB) psql -U $(CONTAINER_ODOO) -d $(WEB_DB_NAME)

logs:
	@if [ "$(word 2, $(MAKECMDGOALS))" = "odoo" ]; then \
		$(DOCKER_COMPOSE) logs -f $(CONTAINER_ODOO); \
	elif [ "$(word 2, $(MAKECMDGOALS))" = "db" ]; then \
		$(DOCKER_COMPOSE) logs -f $(CONTAINER_DB); \
	else \
		echo "Invalid logs target. Use 'make logs odoo' or 'make logs db'."; \
	fi

# =========================
# Fungsi upgrade_addon
# =========================
upgrade_addon = $(DOCKER) exec -it $(CONTAINER_ODOO) odoo -i $(1) -d $(WEB_DB_NAME) --without-demo=all --stop-after-init --log-level=info



# =========================
# Target addon
# =========================
addon:
	@if [ "$$(docker inspect -f '{{.State.Running}}' $(CONTAINER_ODOO) 2>/dev/null)" != "true" ]; then \
		echo "🔄 Container belum jalan, memulai..."; \
		$(DOCKER_COMPOSE) up -d; \
		sleep 10; \
	else \
		echo "✅ Container sudah jalan, langsung upgrade..."; \
	fi
	@echo "🚀 Upgrading addon: $(word 2, $(MAKECMDGOALS))"
	$(call upgrade_addon,$(word 2, $(MAKECMDGOALS)))

# =========================
# Wildcard agar tidak error saat pakai argumen
# =========================
%:
	@:

# =========================
# Phony target
# =========================
.PHONY: start stop restart console psql logs addon help
