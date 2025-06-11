#!/bin/sh
#
# This script dynamically generates the user-mapping.xml for Guacamole
# based on environment variables.

# --- Configuration ---
# The script will read these environment variables.
# GUAC_USER:       The username for logging into the Guacamole web UI.
# GUAC_PASSWORD:   The password for logging into the Guacamole web UI.
# RDP_HOSTNAME:    The hostname or IP address of the target RDP server.
# RDP_PORT:        The port of the target RDP server (default: 3389).
# RDP_USER:        The username for logging into the RDP session.
# RDP_PASSWORD:    The password for logging into the RDP session.

# --- Script Logic ---

# Exit immediately if a command exits with a non-zero status.
set -e

# Check for required variables and exit if they are not set.
if [ -z "$GUAC_USER" ] || [ -z "$GUAC_PASSWORD" ] || [ -z "$RDP_HOSTNAME" ] || [ -z "$RDP_USER" ] || [ -z "$RDP_PASSWORD" ]; then
  echo "Error: One or more required environment variables are not set."
  echo "Please set: GUAC_USER, GUAC_PASSWORD, RDP_HOSTNAME, RDP_USER, RDP_PASSWORD"
  exit 1
fi

# Set a default for the RDP port if it's not provided.
RDP_PORT=${RDP_PORT:-3389}

# Define the full path for the output file.
OUTPUT_FILE="./user-mapping.xml"

echo "Generating Guacamole configuration at: $OUTPUT_FILE"


# Write the user-mapping.xml using a "here document" (cat << EOF).
# This is a clean way to write multi-line text. The variables will be substituted.
cat > "$OUTPUT_FILE" << EOF
<user-mapping>
    <authorize username="$GUAC_USER" password="$GUAC_PASSWORD">
        <connection name="My Remote Desktop">
            <protocol>rdp</protocol>
            <param name="hostname">$RDP_HOSTNAME</param>
            <param name="port">$RDP_PORT</param>
            <param name="ignore-cert">true</param>
            <param name="username">$RDP_USER</param>
            <param name="password">$RDP_PASSWORD</param>
        </connection>
    </authorize>
</user-mapping>
EOF

echo "Configuration generated successfully."
