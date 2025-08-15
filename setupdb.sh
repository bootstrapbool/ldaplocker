# Setup DB
# 
# USAGE: setupdb.sh
#
# Creates secrets.db in the base directory if it does not already exist.

SCRIPT_PATH=$( realpath $0 )
BASE_DIR=$( dirname $SCRIPT_PATH )

SQL_FILEPATH="$BASE_DIR/secrets.sql"
DB_FILEPATH="$BASE_DIR/secrets.db"

create_db () {
    if [ -f $1 ]; then
        echo "Error: Database $1 already exists."
        exit 1
    fi

    cat $SQL_FILEPATH | sqlite3 "$1"
    echo "Successfully created $1"
}

create_db $DB_FILEPATH

# TODO: Finish me
#
# if [ $# -gt 1 ]; then
#     echo "USAGE: setupdb.sh"
#     exit 1
# elif [ $# -eq 0 ]; then
#     exit 0
# fi
# 
# CSV_FILEPATH="$BASE_DIR/secrets.csv"
# $CSV_FILEPATH=$1
# 
# sqlite3 $DB_FILEPATH <<EOF
# .mode csv
# .import --skip 1 $CSV_FILEPATH Secrets
# EOF
