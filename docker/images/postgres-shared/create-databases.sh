#
# Will process each .txt file in DB_USERDATA_HOME
# and configure users, databases, and privileges
# acordingly. Each line in the file is one
# configuration and must be of the format:
#
# database:username:privilege:passwd
#
# Where <privilege> is one of "rw", "ro",
# "none", or "delete". If <passwd> is blank,
# it will be ignored.
#
set -e

: ${POSTGRES_USER:=postgres}
: ${DB_USERDATA_HOME:=/userdata}

get_dbs()
{
  _dbs=$(echo '\l' | psql -qtU "$POSTGRES_USER" | cut -d \| -f1)
  # trim whitespace
  set -- $_dbs
  echo $@
}

get_users()
{
  _users=$(echo '\du' | psql -qtU "$POSTGRES_USER" | cut -d \| -f1)
  # trim whitespace
  set -- $_users
  echo $@
}

db_is_in()
{
  _db=$1
  _set=$2
  for _created in $_set; do
    if [ "$_created" = "$_db" ]; then
      return 0
    fi
  done
  return 1
}

user_is_in()
{
  _user=$1
  _set=$2
  for _created in $_set; do
    if [ "$_created" = "$_user" ]; then
      return 0
    fi
  done
  return 1
}

for userdata_file in $(find $DB_USERDATA_HOME -type f -name '*.txt' -print); do
  IFS=:
  while read db user privilege passwd; do
    IFS=$(printf ' \t\n')

    # Database management - generate statement
    if db_is_in "$db" "$(get_dbs)" || [ -z "$db" ]; then
      db_stmt=""
    else
      echo "creating database $db"
      db_stmt="CREATE DATABASE $db;"
    fi

    # User management - generate statements
    if [ -z "$user" ]; then
      user_stmt=""
    elif [ "$privilege" = 'delete' ]; then
      echo "removing user $user"
      user_stmt="DROP USER IF EXISTS $user;"
    else
      if user_is_in "$user" "$(get_users)"; then
        echo "reconfiguring user $user"
        user_stmt_action=ALTER
      else
        echo "creating user $user"
        user_stmt_action=CREATE
      fi
      user_stmt="$user_stmt_action USER $user"
      if [ -n "$passwd" ]; then
        user_stmt="$user_stmt PASSWORD '$passwd'"
      fi
      user_stmt="$user_stmt;"
    fi

    case $privilege in
        rw) grant_stmt="GRANT ALL ON DATABASE $db TO $user;";;
        ro) grant_stmt="GRANT CONNECT ON DATABASE $db TO $user;";;
      none) grant_stmt="REVOKE ALL ON DATABASE $db FROM $user;";;
         *) grant_stmt="";;
    esac

    # Execute statements 
    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" <<EOSQL
      $db_stmt
      $user_stmt
      $grant_stmt
EOSQL

  IFS=:
  done < "$userdata_file"
IFS=$(printf ' \t\n')
done
