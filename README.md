## Quickstart
```bash
# This will start with an in memory database.

$ docker run -p 3567:3567 -d registry.supertokens.io/supertokens/supertokens-mysql
```

## Configuration
You can use your own `config.yaml` file as a shared volume or pass the key-values as environment variables. 

If you do both, only the shared `config.yaml` file will be considered.
  
#### Using environment variable
Available environment variables
- **Core**
	- API\_KEYS
	- SUPERTOKENS\_HOST
	- SUPERTOKENS\_PORT
	- ACCESS\_TOKEN\_VALIDITY
	- ACCESS\_TOKEN\_BLACKLISTING
	- ACCESS\_TOKEN\_SIGNING\_KEY\_DYNAMIC
	- ACCESS\_TOKEN\_DYNAMIC\_SIGNING\_KEY\_UPDATE\_INTERVAL
	- REFRESH\_TOKEN\_VALIDITY
	- PASSWORD\_RESET\_TOKEN\_LIFETIME
	- EMAIL\_VERIFICATION\_TOKEN\_LIFETIME
	- INFO\_LOG\_PATH
	- ERROR\_LOG\_PATH
    - MAX\_SERVER\_POOL\_SIZE
	- PASSWORDLESS\_MAX\_CODE\_INPUT\_ATTEMPTS
	- PASSWORDLESS\_CODE\_LIFETIME
	- DISABLE\_TELEMETRY
	- BASE\_PATH
	- PASSWORD\_HASHING\_ALG
	- ARGON2\_ITERATIONS
	- ARGON2\_MEMORY\_KB
	- ARGON2\_PARALLELISM
	- ARGON2\_HASHING\_POOL\_SIZE
	- BCRYPT\_LOG\_ROUNDS
	- LOG\_LEVEL
	- FIREBASE\_PASSWORD\_HASHING\_POOL\_SIZE
	- FIREBASE\_PASSWORD\_HASHING\_SIGNER\_KEY
	- IP\_ALLOW\_REGEX
	- IP\_DENY\_REGEX
	- TOTP\_MAX\_ATTEMPTS
	- TOTP\_RATE\_LIMIT\_COOLDOWN\_SEC
	- SUPERTOKENS\_SAAS\_LOAD\_ONLY\_CUD
	- OAUTH\_PROVIDER\_PUBLIC\_SERVICE\_URL
	- OAUTH\_PROVIDER\_ADMIN\_SERVICE\_URL
	- OAUTH\_PROVIDER\_CONSENT\_LOGIN\_BASE\_URL
	- OAUTH\_PROVIDER\_URL\_CONFIGURED\_IN\_OAUTH\_PROVIDER
	- OAUTH\_CLIENT\_SECRET\_ENCRYPTION\_KEY
	- BULK\_MIGRATION\_PARALLELISM
- **MySQL:**
	- MYSQL\_CONNECTION\_URI
	- MYSQL\_USER
	- MYSQL\_PASSWORD
	- MYSQL\_CONNECTION\_POOL\_SIZE
	- MYSQL\_HOST
	- MYSQL\_PORT
	- MYSQL\_DATABASE\_NAME
	- MYSQL\_TABLE\_NAMES\_PREFIX
	- MYSQL\_IDLE\_CONNECTION\_TIMEOUT
	- MYSQL\_MINIMUM\_IDLE\_CONNECTIONS


```bash
docker run \
	-p 3567:3567 \
	-e MYSQL_CONNECTION_URI="mysql://username:password@host:port/dbName" \
	-d registry.supertokens.io/supertokens/supertokens-mysql

# OR

docker run \
	-p 3567:3567 \
	-e MYSQL_USER="mysqlUser" \
	-e MYSQL_HOST="192.168.1.2" \
	-e MYSQL_PORT="3306" \
	-e MYSQL_PASSWORD="password" \
	-d registry.supertokens.io/supertokens/supertokens-mysql
```

#### Using custom config file
- In your `config.yaml` file, please make sure you store the following key / values:
  - `core_config_version: 0`
  - `host: "0.0.0.0"`
  - `mysql_config_version: 0`
  - `info_log_path: null` (to log in docker logs)
  - `error_log_path: null` (to log in docker logs)
- The path for the `config.yaml` file in the container is `/usr/lib/supertokens/config.yaml`

```bash
$ docker run \
	-p 3567:3567 \
	-v /path/to/config.yaml:/usr/lib/supertokens/config.yaml \
	-d registry.supertokens.io/supertokens/supertokens-mysql
```

## Logging
- By default, all the logs will be available via the `docker logs <container-name>` command.
- You can setup logging to a shared volume by:
	- Setting the `info_log_path` and `error_log_path` variables in your `config.yaml` file (or passing the values asn env variables).
	- Mounting the shared volume for the logging directory.

```bash
$ docker run \
	-p 3567:3567 \
	-v /path/to/logsFolder:/home/logsFolder \
	-e INFO_LOG_PATH="/home/logsFolder/info.log" \
	-e ERROR_LOG_PATH="/home/logsFolder/error.log" \
	-e MYSQL_USER="mysqlUser" \
	-e MYSQL_PASSWORD="password" \
	-d registry.supertokens.io/supertokens/supertokens-mysql
```

## Database setup
- Before you start this container, make sure to initialize your database.
- You do not need to ensure that the MySQL database has started before this container is started. During bootup, SuperTokens will wait for ~1 hour for a MySQL instance to be available.
- If `MYSQL_USER`, `MYSQL_PASSWORD` and `MYSQL_CONNECTION_URI` are not provided, then SuperTokens will use an in memory database.


## Read-only root fs
- If you wish to run this container with a read-only root filesystem, you can do so.
- The container still needs a temp area, where it can write its stuff, and also needs to be able to execute from there.
- You will have to create a mount for `/lib/supertokens/temp/`

```bash
docker run \
	-p 3567:3567 \
	--mount source=/path/on/host/machine,destination=/lib/supertokens/temp/,type=bind \
	--read-only \
	-d registry.supertokens.io/supertokens/supertokens-mysql
```

```bash
docker run \
	-p 3567:3567 \
	--tmpfs=/lib/supertokens/temp/:exec \
	--read-only \
	-d registry.supertokens.io/supertokens/supertokens-mysql
```