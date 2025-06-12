#!/bin/sh
#
# This script dynamically generates the user-mapping.xml for Guacamole
# based on environment variables.

# --- Configuration ---
# The script will read these environment variables.
# GUAC_USER:       The username for logging into the Guacamole web UI.
# GUAC_PASSWORD:   The password for logging into the Guacamole web UI.
# REMOTE_DESKTOP_HOSTNAME:    The hostname or IP address of the target remote desktop server.
# REMOTE_DESKTOP_PORT:        The port of the target remote desktop server (default: 3389 -> rdp).
# REMOTE_DESKTOP_PROTOCOL:        The protocol (rdp or vnc) of the target remote desktop server (default: rdp).
# VM_USER:        The username for logging into the remote desktop session.
# VM_PASSWORD:    The password for logging into the remote desktop session.

# --- Script Logic ---

# Exit immediately if a command exits with a non-zero status.
set -e

# Check for required variables and exit if they are not set.
if [ -z "$GUAC_USER" ] || [ -z "$GUAC_PASSWORD" ] || [ -z "$REMOTE_DESKTOP_HOSTNAME" ] || [ -z "$VM_USER" ] || [ -z "$VM_PASSWORD" ]; then
  echo "Error: One or more required environment variables are not set."
  echo "Please set: GUAC_USER, GUAC_PASSWORD, REMOTE_DESKTOP_HOSTNAME, VM_USER, VM_PASSWORD"
  exit 1
fi

# Set a default for the RDP port if it's not provided.
REMOTE_DESKTOP_PORT=${REMOTE_DESKTOP_PORT:-3389}
REMOTE_DESKTOP_PROTOCOL=${REMOTE_DESKTOP_PROTOCOL:-rdp}

# Define the full path for the output file.
OUTPUT_FILE="./user-mapping.xml"

echo "Generating Guacamole configuration at: $OUTPUT_FILE"


# Write the user-mapping.xml using a "here document" (cat << EOF).
# This is a clean way to write multi-line text. The variables will be substituted.
cat > "$OUTPUT_FILE" << EOF
<user-mapping>
    <authorize username="$GUAC_USER" password="$GUAC_PASSWORD">
        <connection name="My Remote Desktop">
            <protocol>$REMOTE_DESKTOP_PROTOCOL</protocol>
            <param name="hostname">$REMOTE_DESKTOP_HOSTNAME</param>
            <param name="port">$REMOTE_DESKTOP_PORT</param>
            <param name="ignore-cert">true</param>
            <param name="username">$VM_USER</param>
            <param name="password">$VM_PASSWORD</param>
        </connection>
    </authorize>
</user-mapping>
EOF

echo "Configuration generated successfully."
