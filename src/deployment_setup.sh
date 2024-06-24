LICENSE_KEY=''
ANALYTICS_API_SECURED="'true'"
ACCESS_TOKEN=''

FILE="rendered-deployment.yaml"

sed -i'' -e "s|\${LICENSE_KEY}|${LICENSE_KEY}|g" "$FILE"
sed -i'' -e "s|\${ANALYTICS_API_SECURED}|${ANALYTICS_API_SECURED}|g" "$FILE"
sed -i'' -e "s|\${ACCESS_TOKEN}|${ACCESS_TOKEN}|g" "$FILE"

