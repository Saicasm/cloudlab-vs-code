# Makefile for CloudLab Multi-Node SSH Setup

# Base Variables
SSH_KEY_DIR := # Path to SSH key dir
SSH_KEY_NAME :=   # Replace with your actual key file name (without .pub extension)
SSH_PUBLIC_KEY := $(SSH_KEY_DIR)/$(SSH_KEY_NAME).pub
SSH_PRIVATE_KEY := $(SSH_KEY_DIR)/$(SSH_KEY_NAME)
VS_CODE_CONFIG_DIR := $(HOME)/.ssh/vscode
CONFIG_FILE := nodes.conf

# Default username for all nodes (can be overridden in nodes.conf)
DEFAULT_USER := Username

# Include node configuration if it exists
-include $(CONFIG_FILE)

# Create a nodes.conf file if it doesn't exist
$(CONFIG_FILE):
	@echo "# CloudLab Nodes Configuration" > $(CONFIG_FILE)
	@echo "# Format: NODE_<number>_HOST := hostname" >> $(CONFIG_FILE)
	@echo "# Format: NODE_<number>_USER := username (optional, defaults to $(DEFAULT_USER))" >> $(CONFIG_FILE)
	@echo "" >> $(CONFIG_FILE)
	@echo "# Example:" >> $(CONFIG_FILE)
	@echo "NODE_1_HOST := rand1234.utah.cloudlab.us" >> $(CONFIG_FILE)
	@echo "NODE_1_USER := $(DEFAULT_USER)" >> $(CONFIG_FILE)
	@echo "NODE_2_HOST := rand1234.utah.cloudlab.us" >> $(CONFIG_FILE)
	@echo "# NODE_2_USER := different_user" >> $(CONFIG_FILE)
	@echo "Configuration file created at $(CONFIG_FILE). Please edit it with your node information."

# Phony targets
.PHONY: all check-key setup-vscode test-connection help add-node clean-config

# Default target
all: $(CONFIG_FILE) check-key setup-vscode test-connection

# Check if the SSH key exists
check-key:
	@echo "Checking SSH key..."
	@if [ ! -f $(SSH_PUBLIC_KEY) ]; then \
		echo "Error: SSH public key not found at $(SSH_PUBLIC_KEY)"; \
		echo "Please ensure your public key file exists at this path or update the SSH_KEY_NAME variable."; \
		exit 1; \
	fi
	@if [ ! -f $(SSH_PRIVATE_KEY) ]; then \
		echo "Error: SSH private key not found at $(SSH_PRIVATE_KEY)"; \
		echo "Please ensure your private key file exists at this path."; \
		exit 1; \
	fi
	@echo "SSH key found."
	@echo "Your public key is:"
	@cat $(SSH_PUBLIC_KEY)
	@echo "Please ensure this key is added to your CloudLab profile"

# Setup VS Code SSH config for all nodes
setup-vscode: $(CONFIG_FILE)
	@echo "Setting up VS Code SSH config..."
	@mkdir -p $(VS_CODE_CONFIG_DIR)
	@rm -f $(VS_CODE_CONFIG_DIR)/cloudlab-config
	@for n in $$(seq 1 100); do \
		host_var="NODE_$${n}_HOST"; \
		user_var="NODE_$${n}_USER"; \
		if [ -n "$${!host_var}" ]; then \
			echo "Setting up node $$n: $${!host_var}"; \
			echo "Host cloudlab-$$n" >> $(VS_CODE_CONFIG_DIR)/cloudlab-config; \
			echo "    HostName $${!host_var}" >> $(VS_CODE_CONFIG_DIR)/cloudlab-config; \
			if [ -n "$${!user_var}" ]; then \
				echo "    User $${!user_var}" >> $(VS_CODE_CONFIG_DIR)/cloudlab-config; \
			else \
				echo "    User $(DEFAULT_USER)" >> $(VS_CODE_CONFIG_DIR)/cloudlab-config; \
			fi; \
			echo "    IdentityFile $(SSH_PRIVATE_KEY)" >> $(VS_CODE_CONFIG_DIR)/cloudlab-config; \
			echo "    IdentitiesOnly yes" >> $(VS_CODE_CONFIG_DIR)/cloudlab-config; \
			echo "" >> $(VS_CODE_CONFIG_DIR)/cloudlab-config; \
		fi; \
	done
	@echo "VS Code SSH config created at $(VS_CODE_CONFIG_DIR)/cloudlab-config"

# Test SSH connection to all nodes
test-connection: $(CONFIG_FILE)
	@echo "Testing SSH connections..."
	@for n in $$(seq 1 100); do \
		host_var="NODE_$${n}_HOST"; \
		user_var="NODE_$${n}_USER"; \
		if [ -n "$${!host_var}" ]; then \
			user=$${!user_var:-$(DEFAULT_USER)}; \
			echo "Testing connection to node $$n: $${!host_var}"; \
			ssh -i $(SSH_PRIVATE_KEY) -o IdentitiesOnly=yes -o ConnectTimeout=5 $$user@$${!host_var} exit || \
				echo "Failed to connect to node $$n: $${!host_var}"; \
		fi; \
	done

# Add a new node interactively
add-node: $(CONFIG_FILE)
	@n=$$(grep -c "NODE_.*_HOST" $(CONFIG_FILE)); \
	n=$$((n + 1)); \
	echo "Adding node $$n"; \
	read -p "Enter hostname: " hostname; \
	read -p "Enter username [$(DEFAULT_USER)]: " username; \
	echo "" >> $(CONFIG_FILE); \
	echo "NODE_$${n}_HOST := $$hostname" >> $(CONFIG_FILE); \
	if [ -n "$$username" ]; then \
		echo "NODE_$${n}_USER := $$username" >> $(CONFIG_FILE); \
	fi; \
	echo "Node $$n added to configuration."

# Clean configuration
clean-config:
	@rm -f $(CONFIG_FILE)
	@echo "Configuration file removed. Run 'make' to create a new one."

# Help target
help:
	@echo "Available targets:"
	@echo "  all           : Run all setup steps (default)"
	@echo "  check-key     : Verify SSH key existence"
	@echo "  setup-vscode  : Create VS Code SSH configuration for all nodes"
	@echo "  test-connection: Test SSH connection to all nodes"
	@echo "  add-node      : Add a new node interactively"
	@echo "  clean-config  : Remove the configuration file"
	@echo "  help          : Show this help message"
	@echo ""
	@echo "Configuration:"
	@echo "  - Edit nodes.conf to specify your CloudLab nodes"
	@echo "  - Update SSH_KEY_NAME in the Makefile with your key file name"
	@echo ""
	@echo "Usage:"
	@echo "  1. Run 'make' to create initial configuration"
	@echo "  2. Edit nodes.conf with your node information"
	@echo "  3. Run 'make' again to set up all nodes"
	@echo "  4. Use 'make add-node' to add more nodes interactively"