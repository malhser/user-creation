
#!/bin/bash

# Stop on errors and unset variables
set -Eeuo pipefail

# Step 1: Check root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run this script as root or using sudo"
    exit 1
fi

# Step 2: Read username argument
USERNAME="${1:-}"

if [ -z "$USERNAME" ]; then
    echo "Usage: sudo ./onboard_user.sh <username>"
    exit 1
fi

# Validate Linux username format
if [[ ! "$USERNAME" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
    echo "Error: Invalid username format."
    exit 1
fi

# Step 3: Check whether user already exists
if id "$USERNAME" &>/dev/null; then
    echo "Error: User $USERNAME already exists."
    exit 1
fi

# Step 4: Check required commands
for cmd in useradd chpasswd chage openssl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: Required command $cmd is missing."
        exit 1
    fi
done

# Step 5: Configure secure audit log
LOG_FILE="/var/log/user_onboarding.log"

touch "$LOG_FILE"
chmod 600 "$LOG_FILE"

# Step 6: Generate a secure random password
TEMP_PASS=$(openssl rand -hex 16)

# Step 7: Create user with home directory
if ! useradd -m "$USERNAME"; then
    echo "Error: Failed to create user."
    exit 1
fi

# Step 8: Set temporary password
if ! printf '%s:%s\n' "$USERNAME" "$TEMP_PASS" | chpasswd; then
    userdel -r "$USERNAME" 2>/dev/null || true
    echo "Error: Failed to set password."
    exit 1
fi

# Step 9: Force password change at first login
if ! chage -d 0 "$USERNAME"; then
    userdel -r "$USERNAME" 2>/dev/null || true
    echo "Error: Failed to expire password."
    exit 1
fi

# Step 10: Record successful operation
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

printf '%s | SUCCESS | User: %s | Created by UID: %s\n' \
    "$TIMESTAMP" "$USERNAME" "$EUID" >> "$LOG_FILE"

# Step 11: Display temporary credentials
echo "-------------------------------------"
echo "User created successfully!"
echo "Username: $USERNAME"
echo "Temporary password: $TEMP_PASS"
echo "Password change required at first login."
echo "Audit log: $LOG_FILE"
echo "-------------------------------------"
