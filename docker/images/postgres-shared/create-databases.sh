set -e

: ${POSTGRES_USER:=postgres}

DB_USERDATA_HOME=/userdata

have_db()
{
  _db=$1
  for _created in $CREATED_DBS; do
    if [ "$_created" = "$_db" ]; then
      return 0
    fi
  done
  return 1
}

have_user()
{
  _user=$1
  for _created in $CREATED_USERS; do
    if [ "$_created" = "$_user" ]; then
      return 0
    fi
  done
  return 1
}

CREATED_DBS=$(echo '\l' | psql -qtU "$POSTGRES_USER" | cut -d \| -f1)
CREATED_USERS=$(echo '\du' | psql -qtU "$POSTGRES_USER" | cut -d \| -f1)

# Get rid of crufty whitespace
saved_args=$@
set -- $CREATED_DBS
CREATED_DBS=$@
set -- $CREATED_USERS
CREATED_USERS=$@
set -- $saved_args

for userdata_file in $(find $DB_USERDATA_HOME -type f -name '*.txt' -print); do
  while read db passwd; do

    if have_db "$db"; then
      echo "found database $db"
    else
      echo "creating database $db"
      psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" <<EOSQL
        CREATE DATABASE $db;
EOSQL
    fi

    user_action=
    if have_user "$db"; then
      echo "found user $db"
      user_action=ALTER
    else
      echo "creating user $db"
      user_action=CREATE
    fi

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" <<EOSQL
      $user_action USER $db PASSWORD '$passwd';
      GRANT ALL PRIVILEGES ON DATABASE $db to $db;
EOSQL

  done < "$userdata_file"
done
