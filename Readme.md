# CloudLab Multi-Node Setup

This repository contains tools for managing SSH connections to multiple CloudLab nodes, particularly useful for VS Code remote development.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [File Structure](#file-structure)
- [Troubleshooting](#troubleshooting)
- [Advanced Usage](#advanced-usage)

## Prerequisites

Before you begin, ensure you have:

- An active CloudLab account
- SSH keys generated and added to your CloudLab profile
- Visual Studio Code installed with the "Remote - SSH" extension
- Make utility installed on your system

## Installation

1. Clone or download this repository to your local machine:

   ```bash
   git clone https://github.com/Saicasm/cloudlab-vs-code.git
   cd cloudlab-setup
   ```

2. Update the Makefile with your SSH key information:
   ```makefile
   SSH_KEY_DIR := path_to_your_dir
   SSH_KEY_NAME := your_key_file  # without .pub extension
   ```

## Configuration

### Initial Setup

1. Generate the initial configuration:

   ```bash
   make
   ```

   This will create a `nodes.conf` file with example entries.

2. Edit `nodes.conf` to add your CloudLab nodes:
   ```makefile
   # CloudLab Nodes Configuration
   NODE_1_HOST := rand123.utah.cloudlab.us
   NODE_1_USER := Username
   NODE_2_HOST := rand123.utah.cloudlab.us
   NODE_2_USER := Username
   ```

### Adding Nodes

You can add nodes in two ways:

1. Interactively using make:

   ```bash
   make add-node
   ```

2. Manually by editing `nodes.conf`

## Usage

### Basic Commands

- Set up everything (recommended for first time):

  ```bash
  make
  ```

- Check SSH key configuration:

  ```bash
  make check-key
  ```

- Set up VS Code configuration:

  ```bash
  make setup-vscode
  ```

- Test connections to all nodes:

  ```bash
  make test-connection
  ```

- Add a new node interactively:

  ```bash
  make add-node
  ```

- Clean configuration:

  ```bash
  make clean-config
  ```

- Show help:
  ```bash
  make help
  ```

### Using with VS Code

1. Open VS Code
2. Press `Ctrl/Cmd + Shift + P`
3. Type "Remote-SSH: Connect to Host..."
4. Select your node (e.g., `cloudlab-1`, `cloudlab-2`, etc.)

## File Structure

```
.
├── Makefile              # Main configuration and automation file
├── nodes.conf            # Node configuration file (generated)
└── README.md            # This documentation file
```

## Troubleshooting

### Common Issues

1. Permission denied (publickey):

   - Verify your SSH key is correctly added to CloudLab
   - Check key permissions: `chmod 600` for private key, `chmod 644` for public key
   - Ensure correct username in nodes.conf

2. Connection timeout:

   - Verify the hostname is correct
   - Check if your CloudLab experiment is still active
   - Ensure you're connected to the internet

3. VS Code can't find the host:
   - Run `make setup-vscode` again
   - Check `~/.ssh/vscode/cloudlab-config` exists
   - Restart VS Code

### Debug Steps

1. Check SSH key configuration:

   ```bash
   make check-key
   ```

2. Test specific connection:

   ```bash
   ssh -i /path/to/your/key -vv username@hostname
   ```

3. Verify VS Code configuration:
   ```bash
   cat ~/.ssh/vscode/cloudlab-config
   ```

## Advanced Usage

### Multiple Key Support

To use different SSH keys for different nodes, modify `nodes.conf`:

```makefile
NODE_1_HOST := host1.cloudlab.us
NODE_1_USER := user1
NODE_1_KEY := /path/to/key1

NODE_2_HOST := host2.cloudlab.us
NODE_2_USER := user2
NODE_2_KEY := /path/to/key2
```

### Batch Operations

To perform operations on specific nodes:

```bash
# Test specific node
ssh -i $SSH_KEY_PATH $USER@$(NODE_1_HOST)

# Copy files to all nodes
for node in $(NODES); do
    scp -i $SSH_KEY_PATH files $USER@$node:~/
done
```
