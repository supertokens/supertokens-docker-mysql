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
	- ACCESS\_TOKEN\_SIGNING\_KEY\_UPDATE\_INTERVAL
	- REFRESH\_TOKEN\_VALIDITY
	- PASSWORD\_RESET\_TOKEN\_LIFETIME
	- EMAIL\_VERIFICATION\_TOKEN\_LIFETIME
	- INFO\_LOG\_PATH
	- ERROR\_LOG\_PATH
    - MAX\_SERVER\_POOL\_SIZE
	- DISABLE\_TELEMETRY
- **MySQL:**
	- MYSQL\_CONNECTION\_URI
	- MYSQL\_USER
	- MYSQL\_PASSWORD
	- MYSQL\_CONNECTION\_POOL\_SIZE
	- MYSQL\_HOST
	- MYSQL\_PORT
	- MYSQL\_DATABASE\_NAME
	- MYSQL\_TABLE\_NAMES\_PREFIX


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