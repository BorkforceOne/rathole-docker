#!/bin/sh
set -e

echo "--- Rathole Docker Startup ---"

# 1. Check if CONFIG is provided
if [ -z "$CONFIG" ]; then
    echo "Error: CONFIG environment variable is not set."
    exit 1
fi

# 2. Clean and write the configuration
echo "Processing configuration..."

# We use a temporary file to avoid pipe issues and ensure atomicity
# 1. Clean up "CONFIG=" prefix if it was included in the value
# 2. Convert CRLF to LF
# 3. Remove non-printable control characters
# 4. Remove leading empty lines
cat <<EOF > /tmp/config.raw
$CONFIG
EOF

sed -i '1s/^[[:space:]]*CONFIG=[[:space:]]*//' /tmp/config.raw
tr -d '\r' < /tmp/config.raw | tr -d '\000-\010\013\014\016-\037' > /tmp/config.clean
sed -e '/./,$!d' /tmp/config.clean > /app/config.toml

rm -f /tmp/config.raw /tmp/config.clean

# 3. Basic Sanity Checks
if [ ! -s /app/config.toml ]; then
    echo "Error: Resulting config.toml is empty. Please check your CONFIG environment variable."
    exit 1
fi

if ! grep -qE "\[(client|server)\]" /app/config.toml; then
    echo "Warning: No [client] or [server] block detected in config.toml."
fi

echo "Configuration successfully written to /app/config.toml"

# 4. Start Rathole
if [ "$#" -eq 0 ]; then
    echo "Starting rathole with /app/config.toml..."
    exec /usr/local/bin/rathole /app/config.toml
else
    echo "Starting rathole with custom arguments: $@"
    exec /usr/local/bin/rathole "$@"
fi