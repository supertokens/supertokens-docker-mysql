#!/bin/bash
set -eo pipefail
# -e  Exit immediately if a command exits with a non-zero status.
# -o pipefail the return value of a pipeline is the status of the last command
#    to exit with a non-zero status, or zero if no command exited with a non-zero status

CONFIG_HASH=$(head -n 1 /CONFIG_HASH)

ERROR="\x1b[1;31m"
DEFAULT="\x1b[0m"

# logging functions
log() {
    local level="$1"; shift
    local type="$1"; shift
	printf "[$level$type$DEFAULT]: $*\n"
}
error_log() {
	log "$ERROR" "$@" >&2
    exit 1
}

# if command starts with an option, prepend supertokens start
if [ "${1}" = 'dev' -o "${1}" = "production" -o "${1:0:2}" = "--" ]; then
    # set -- supertokens start "$@"
    set -- supertokens start "$@"
    # check if --foreground option is passed or not
    if [[ "$*" != *--foreground* ]]
    then
        set -- "$@" --foreground
    fi
fi

CONFIG_FILE=/usr/lib/supertokens/config.yaml
CONFIG_MD5SUM="$(md5sum /usr/lib/supertokens/config.yaml | awk '{ print $1 }')"

# if files have been shared using shared volumes, make sure the ownership of the
# /usr/lib/supertokens files still remains with supertokens user
chown -R supertokens:supertokens /usr/lib/supertokens/

if [ "$CONFIG_HASH" = "$CONFIG_MD5SUM" ]
then
    echo "" >> $CONFIG_FILE
    echo "host: 0.0.0.0" >> $CONFIG_FILE

    # verify api keys are passed
    if [ ! -z $API_KEYS ]
    then
        echo "api_keys: $API_KEYS" >> $CONFIG_FILE
    fi
    
    # verify mysql user name is passed
    if [ ! -z $MYSQL_USER ]
    then
        echo "mysql_user: $MYSQL_USER" >> $CONFIG_FILE
    fi

    # verify mysql password is passed
    if [ ! -z $MYSQL_PASSWORD ]
    then
        echo "mysql_password: $MYSQL_PASSWORD" >> $CONFIG_FILE
    fi

    # check if supertokens port is passed
    if [ ! -z $SUPERTOKENS_PORT ]
    then
        echo "port: $SUPERTOKENS_PORT" >> $CONFIG_FILE
    fi

    # check if access token validity is passed
    if [ ! -z $ACCESS_TOKEN_VALIDITY ]
    then
        echo "access_token_validity: $ACCESS_TOKEN_VALIDITY" >> $CONFIG_FILE
    fi

    # check if access token blacklisting is passed
    if [ ! -z $ACCESS_TOKEN_BLACKLISTING ]
    then
        echo "access_token_blacklisting: $ACCESS_TOKEN_BLACKLISTING" >> $CONFIG_FILE
    fi

    # check if access token signing key dynamic is passed
    if [ ! -z $ACCESS_TOKEN_SIGNING_KEY_DYNAMIC ]
    then
        echo "access_token_signing_key_dynamic: $ACCESS_TOKEN_SIGNING_KEY_DYNAMIC" >> $CONFIG_FILE
    fi

    # check if access token signing key update interval is passed
    if [ ! -z $ACCESS_TOKEN_SIGNING_KEY_UPDATE_INTERVAL ]
    then
        echo "access_token_signing_key_update_interval: $ACCESS_TOKEN_SIGNING_KEY_UPDATE_INTERVAL" >> $CONFIG_FILE
    fi

    if [ ! -z $PASSWORD_RESET_TOKEN_LIFETIME ]
    then
        echo "password_reset_token_lifetime: $PASSWORD_RESET_TOKEN_LIFETIME" >> $CONFIG_FILE
    fi

    if [ ! -z $EMAIL_VERIFICATION_TOKEN_LIFETIME ]
    then
        echo "email_verification_token_lifetime: $EMAIL_VERIFICATION_TOKEN_LIFETIME" >> $CONFIG_FILE
    fi

    # check if refresh token validity is passed
    if [ ! -z $REFRESH_TOKEN_VALIDITY ]
    then
        echo "refresh_token_validity: $REFRESH_TOKEN_VALIDITY" >> $CONFIG_FILE
    fi

    if [ ! -z $PASSWORDLESS_MAX_CODE_INPUT_ATTEMPTS ]
    then
        echo "passwordless_max_code_input_attempts: $PASSWORDLESS_MAX_CODE_INPUT_ATTEMPTS" >> $CONFIG_FILE
    fi

    if [ ! -z $PASSWORDLESS_CODE_LIFETIME ]
    then
        echo "passwordless_code_lifetime: $PASSWORDLESS_CODE_LIFETIME" >> $CONFIG_FILE
    fi

    # check if info log path is not passed
    if [ ! -z $INFO_LOG_PATH ]
    then
        if [[ ! -f $INFO_LOG_PATH ]]
        then
            touch $INFO_LOG_PATH
        fi
        # make sure supertokens user has write permission on the file
        chown supertokens:supertokens $INFO_LOG_PATH
        chmod +w $INFO_LOG_PATH
        echo "info_log_path: $INFO_LOG_PATH" >> $CONFIG_FILE
    else
        echo "info_log_path: null" >> $CONFIG_FILE
    fi

    # check if error log path is passed
    if [ ! -z $ERROR_LOG_PATH ]
    then
        if [[ ! -f $ERROR_LOG_PATH ]]
        then
            touch $ERROR_LOG_PATH
        fi
        # make sure supertokens user has write permission on the file
        chown supertokens:supertokens $ERROR_LOG_PATH
        chmod +w $ERROR_LOG_PATH
        echo "error_log_path: $ERROR_LOG_PATH" >> $CONFIG_FILE
    else
        echo "error_log_path: null" >> $CONFIG_FILE
    fi

    # check if telemetry config is passed
    if [ ! -z $DISABLE_TELEMETRY ]
    then
        echo "disable_telemetry: $DISABLE_TELEMETRY" >> $CONFIG_FILE
    fi

    # check if max server pool size is passed
    if [ ! -z $MAX_SERVER_POOL_SIZE ]
    then
        echo "max_server_pool_size: $MAX_SERVER_POOL_SIZE" >> $CONFIG_FILE
    fi

    # check if max server pool size is passed
    if [ ! -z $MYSQL_CONNECTION_POOL_SIZE ]
    then
        echo "mysql_connection_pool_size: $MYSQL_CONNECTION_POOL_SIZE" >> $CONFIG_FILE
    fi

    # check if mysql host is passed
    if [ ! -z $MYSQL_HOST ]
    then
        echo "mysql_host: $MYSQL_HOST" >> $CONFIG_FILE
    fi

    # check if mysql port is passed
    if [ ! -z $MYSQL_PORT ]
    then
        echo "mysql_port: $MYSQL_PORT" >> $CONFIG_FILE
    fi

    # check if mysql database name is passed
    if [ ! -z $MYSQL_DATABASE_NAME ]
    then
        echo "mysql_database_name: $MYSQL_DATABASE_NAME" >> $CONFIG_FILE
    fi

    # check if mysql table name prefix is passed
    if [ ! -z $MYSQL_TABLE_NAMES_PREFIX ]
    then
        echo "mysql_table_names_prefix: $MYSQL_TABLE_NAMES_PREFIX" >> $CONFIG_FILE
    fi

    if [ ! -z $MYSQL_CONNECTION_URI ]
    then
        echo "mysql_connection_uri: $MYSQL_CONNECTION_URI" >> $CONFIG_FILE
    fi

    # THE CONFIGS BELOW ARE DEPRECATED----------------

    # check if mysql key value table name is passed
    if [ ! -z $MYSQL_KEY_VALUE_TABLE_NAME ]
    then
        echo "mysql_key_value_table_name: $MYSQL_KEY_VALUE_TABLE_NAME" >> $CONFIG_FILE
    fi

    # check if mysql session info table name is passed
    if [ ! -z $MYSQL_SESSION_INFO_TABLE_NAME ]
    then
        echo "mysql_session_info_table_name: $MYSQL_SESSION_INFO_TABLE_NAME" >> $CONFIG_FILE
    fi

    # check if mysql emailpassword user table name is passed
    if [ ! -z $MYSQL_EMAILPASSWORD_USERS_TABLE_NAME ]
    then
        echo "mysql_emailpassword_users_table_name: $MYSQL_EMAILPASSWORD_USERS_TABLE_NAME" >> $CONFIG_FILE
    fi

    # check if mysql emailpassword password reset table name is passed
    if [ ! -z $MYSQL_EMAILPASSWORD_PSWD_RESET_TOKENS_TABLE_NAME ]
    then
        echo "mysql_emailpassword_pswd_reset_tokens_table_name: $MYSQL_EMAILPASSWORD_PSWD_RESET_TOKENS_TABLE_NAME" >> $CONFIG_FILE
    fi

    # check if mysql emailpassword email verification tokens table name is passed
    if [ ! -z $MYSQL_EMAILVERIFICATION_TOKENS_TABLE_NAME ]
    then
        echo "mysql_emailpassword_email_verification_tokens_table_name: $MYSQL_EMAILVERIFICATION_TOKENS_TABLE_NAME" >> $CONFIG_FILE
    fi

    # check if mysql verified emails table name is passed
    if [ ! -z $MYSQL_EMAILVERIFICATION_VERIFIED_EMAILS_TABLE_NAME ]
    then
        echo "mysql_emailverification_verified_emails_table_name: $MYSQL_EMAILVERIFICATION_VERIFIED_EMAILS_TABLE_NAME" >> $CONFIG_FILE
    fi

    if [ ! -z $MYSQL_THIRDPARTY_USERS_TABLE_NAME ]
    then
        echo "mysql_thirdparty_users_table_name: $MYSQL_THIRDPARTY_USERS_TABLE_NAME" >> $CONFIG_FILE
    fi
fi

# check if no options has been passed to docker run
if [[ "$@" == "supertokens start" ]]
then
    set -- "$@" --foreground
fi

# If container is started as root user, restart as dedicated supertokens user
if [ "$(id -u)" = "0" ] && [ "$1" = 'supertokens' ]; then
    exec gosu supertokens "$@"
else
    exec "$@"
fi