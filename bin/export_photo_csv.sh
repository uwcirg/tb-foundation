#!/bin/sh -e

usage() {
    cat << USAGE >&2
Usage:
    $cmdname [-h] [-b backup_location]
    -h     Show this help message
    -b     Override default backup location (/tmp)

    Export a CSV of coded photo submissions
USAGE
    exit 1
}


while getopts "hb:" option; do
    case "${option}" in
        b)
            output_dir="${OPTARG}"
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

DEFAULT_OUTPUT_DIR=/tmp
OUTPUT_DIR="${output_dir:-$DEFAULT_OUTPUT_DIR}"


if docker-compose exec web bash -c "bundle exec rake export:v2_photo_report_csv"; then
    echo "Exported CSV within container"
else
    echo "Failed to export CSV within container"
    exit 1
fi

container_name=$(docker compose ps --format json web | jq -r '.[0].Name')


if docker cp $container_name:/foundation/tmp/photo_reports_v2.csv $OUTPUT_DIR; then
    echo "Saved CSV to host"
else
    echo "Error saving csv to host"
    exit 1
fi


