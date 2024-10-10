set -e
# build image
docker build -t supertokens-mysql:circleci .

test_equal () {
    if [[ $1 -ne $2 ]]
    then
        printf "\x1b[1;31merror\x1b[0m from test_equal in $3\n"
        exit 1
    fi
}

no_of_running_containers () {
    docker ps -q | wc -l
}

test_hello () {
    message=$1
    STATUS_CODE=$(curl -I -X GET http://127.0.0.1:3567/hello -o /dev/null -w '%{http_code}\n' -s)
    if [[ $STATUS_CODE -ne "200" ]]
    then
        printf "\x1b[1;31merror\xd1b[0m from test_hello in $message\n"
        exit 1
    fi
}

test_session_post () {
    message=$1
    STATUS_CODE=$(curl -X POST http://127.0.0.1:3567/recipe/session -H "Content-Type: application/json" -d '{
        "userId": "testing",
        "userDataInJWT": {},
        "userDataInDatabase": {},
        "enableAntiCsrf": true
    }' -o /dev/null -w '%{http_code}\n' -s)
    if [[ $STATUS_CODE -ne "200" ]]
    then
        printf "\x1b[1;31merror\xd1b[0m from test_session_post in $message\n"
        exit 1
    fi
}

no_of_containers_running_at_start=`no_of_running_containers`

# start mysql server
docker run -e DISABLE_TELEMETRY=true --rm -d -p 3306:3306 --name mysql -e MYSQL_ROOT_PASSWORD=root mysql

sleep 26s

docker exec mysql mysql -u root --password=root -e "CREATE DATABASE supertokens;"

# setting network options for testing
OS=`uname`
MYSQL_IP=$(ip a | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" | grep -v 127.0.0.1 | awk '{ print $2 }' | cut -f2 -d: | head -n1 | grep -o -E "([0-9]{1,3}\.){3}[0-9]{1,3}")
NETWORK_OPTIONS="-p 3567:3567 -e MYSQL_HOST=$MYSQL_IP"
NETWORK_OPTIONS_CONNECTION_URI="-p 3567:3567 -e MYSQL_CONNECTION_URI=mysql://root:root@$MYSQL_IP:3306"
printf "\nmysql_host: \"$MYSQL_IP\"" >> $PWD/config.yaml

#---------------------------------------------------
# start with no network options
docker run -e DISABLE_TELEMETRY=true --rm -d --name supertokens supertokens-mysql:circleci --no-in-mem-db 

sleep 10s

test_equal `no_of_running_containers` $((no_of_containers_running_at_start+1)) "start with no network options"

#---------------------------------------------------
# start with no network options, but in mem db
docker run -e DISABLE_TELEMETRY=true -p 3567:3567 --rm -d --name supertokens supertokens-mysql:circleci

sleep 17s

test_equal `no_of_running_containers` $((no_of_containers_running_at_start+2)) "start with no network options, but in mem db"

test_hello "start with no network options, but in mem db"

test_session_post "start with no network options, but in mem db"

docker rm supertokens -f

#---------------------------------------------------
# start with mysql password
docker run -e DISABLE_TELEMETRY=true $NETWORK_OPTIONS -e MYSQL_PASSWORD=root --rm -d --name supertokens supertokens-mysql:circleci --no-in-mem-db

sleep 10s

test_equal `no_of_running_containers` $((no_of_containers_running_at_start+1)) "start with mysql password"

#---------------------------------------------------
# start with mysql user
docker run -e DISABLE_TELEMETRY=true $NETWORK_OPTIONS -e MYSQL_USER=root --rm -d --name supertokens supertokens-mysql:circleci --no-in-mem-db

sleep 10s

test_equal `no_of_running_containers` $((no_of_containers_running_at_start+1)) "start with mysql user"

#---------------------------------------------------
# start with mysql user, mysql password
docker run -e DISABLE_TELEMETRY=true $NETWORK_OPTIONS -e MYSQL_USER=root -e MYSQL_PASSWORD=root --rm -d --name supertokens supertokens-mysql:circleci --no-in-mem-db

sleep 17s

test_equal `no_of_running_containers` $((no_of_containers_running_at_start+2)) "start with mysql user, mysql password"

test_hello "start with mysql user, mysql password"

test_session_post "start with mysql user, mysql password"

docker rm supertokens -f

#---------------------------------------------------
# start with mysql connectionURI
docker run -e DISABLE_TELEMETRY=true $NETWORK_OPTIONS_CONNECTION_URI --rm -d --name supertokens supertokens-mysql:circleci --no-in-mem-db

sleep 17s

test_equal `no_of_running_containers` $((no_of_containers_running_at_start+2)) "start with mysql connectionURI"

test_hello "start with mysql connectionURI"

test_session_post "start with mysql connectionURI"

docker rm supertokens -f

#---------------------------------------------------
# start by sharing config.yaml
docker run -e DISABLE_TELEMETRY=true $NETWORK_OPTIONS -v $PWD/config.yaml:/usr/lib/supertokens/config.yaml --rm -d --name supertokens supertokens-mysql:circleci --no-in-mem-db

sleep 17s

test_equal `no_of_running_containers` $((no_of_containers_running_at_start+2)) "start by sharing config.yaml"

test_hello "start by sharing config.yaml"

test_session_post "start by sharing config.yaml"

docker rm supertokens -f

# ---------------------------------------------------
# test info path
#making sure that the user in the container has rights to the mounted volume
mkdir $PWD/sthome
chmod a+rw sthome

docker run -e DISABLE_TELEMETRY=true $NETWORK_OPTIONS -v $PWD/sthome:/home/supertokens -e MYSQL_USER=root -e MYSQL_PASSWORD=root -e INFO_LOG_PATH=/home/supertokens/info.log -e ERROR_LOG_PATH=/home/supertokens/error.log --rm -d --name supertokens supertokens-mysql:circleci --no-in-mem-db

sleep 17s

test_equal `no_of_running_containers` $((no_of_containers_running_at_start+2)) "test info path"

test_hello "test info path"

test_session_post "test info path"

if [[ ! -f $PWD/sthome/info.log || ! -f $PWD/sthome/error.log ]]
then
    exit 1
fi

docker rm supertokens -f

git checkout $PWD/config.yaml

docker rm mysql -f

printf "\x1b[1;32m%s\x1b[0m\n" "success"
exit 0