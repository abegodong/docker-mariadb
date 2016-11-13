#!/bin/sh
set -e

mkdir -p /data/log/mysql
mkdir -p /data/db/mysql/
mkdir -p /data/conf
mkdir -p /var/run/mysqld

if [ ! -f /data/db/mysql/ibdata1 ]; then

    mysql_install_db --datadir="/data/db/mysql"

    tempSqlFile='/tmp/mysql-first-time.sql'

    cat > "$tempSqlFile" <<EOSQL
DELETE FROM mysql.user ;
CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
DROP DATABASE IF EXISTS test ;
EOSQL

    if [ "$MYSQL_DATABASE" ]; then
        echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" >> "$tempSqlFile"
    fi

    if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
        echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" >> "$tempSqlFile"

        if [ "$MYSQL_DATABASE" ]; then
            echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' ;" >> "$tempSqlFile"
        fi
    fi

    echo 'FLUSH PRIVILEGES ;' >> "$tempSqlFile"

    echo "=> Starting MySQL Server"

    exec /usr/bin/mysqld_safe > /dev/null 2>&1 &

    PID=$!

    RET=1

    while [[ $RET -ne 0 ]]; do
        echo "=> Waiting for confirmation of MySQL service startup"
        sleep 5
        mysql -e "status" > /dev/null 2>&1
        RET=$?
    done

    echo "   Started with PID ${PID}"

    echo "=> Importing SQL file"
    mysql -uroot < /tmp/mysql-first-time.sql
    rm -f /tmp/mysql-first-time.sql
    echo "=> Stopping MySQL Server"
    mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
    echo "=> Done!"
fi

mysqld
mysqld_safe
