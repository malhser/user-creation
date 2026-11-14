
# Automated Linux User Onboarding

## Problem Statement

Creating multiple Linux users manually is time-consuming
and can introduce security mistakes.

This Bash script automates account creation while enforcing
root privileges, random temporary passwords and first-login
password changes.

## Features

- Root privilege verification
- Username validation
- Existing-user detection
- Automatic home directory creation
- Random password generation
- Forced password change
- Secure audit logging

## Random Password Generation

The script uses:

    openssl rand -hex 16

This generates a random 32-character hexadecimal password
from 16 random bytes.

## Execution

    chmod 700 onboard_user.sh
    sudo ./onboard_user.sh jdoe

## Password Expiration

    chage -d 0 jdoe

## Audit Log

Location:

    /var/log/user_onboarding.log

Example:

    2026-11-14 19:30:00 | SUCCESS | User: jdoe | Created by UID: 0

## Testing

1. Run without sudo.
2. Run without a username.
3. Try an existing username.
4. Create a new user.
5. Verify the home directory.
6. Verify password expiration.
7. Verify audit logging.

## Security

- Script permissions: 700
- Audit log permissions: 600
- Temporary passwords are not written to the log.
- Users must change their temporary password.

## Screenshot

Add a screenshot showing successful execution
and the audit log entry.
# user-creation
