#!/bin/bash

# build keycloak
KC_DB_AUTOMATIC_MIGRATION="${KC_UPGRADE_FLAG+x}"
${KEYCLOAK_HOME}/bin/kc.sh build

# configure mobileum realm
if [[ ! -z "$REALM_DETAILS" ]]; then
    ${KEYCLOAK_HOME}/script/create_realm.sh
fi

# starting keycloak
${KEYCLOAK_HOME}/bin/kc.sh start --optimized --import-realm ${KC_DB_AUTOMATIC_MIGRATION}