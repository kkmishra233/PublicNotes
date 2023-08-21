#!/bin/bash

COMMON_REALM_APTH="${KEYCLOAK_HOME}/script/"
EXPORT_REALM_PATH="${KEYCLOAK_HOME}/data/import"
TEMP_FILES_PATH="/tmp/"

if [[ -z "$REALM_DETAILS" ]]; then
echo 'use default master realm'
else
echo "creating mobilem realm "
echo ${REALM_DETAILS} > ${TEMP_FILES_PATH}/realm_details.json

#### prepare client ###
cat ${TEMP_FILES_PATH}/realm_details.json | jq -r '.client[].name' | while read clientname ; do

  ROOT_URL=`cat ${TEMP_FILES_PATH}/realm_details.json | jq -r '.client[] | select(.name=='\"${clientname}\"')' | jq -r '.rootUrl'`
  ADMIN_URL=`cat ${TEMP_FILES_PATH}/realm_details.json | jq -r '.client[] | select(.name=='\"${clientname}\"')' | jq -r '.adminUrl'`
  REDIRECT_URL=`cat ${TEMP_FILES_PATH}/realm_details.json | jq -r '.client[] | select(.name=='\"${clientname}\"')' | jq -r '.redirectUri'`
  WEBORIGIN_URL=`cat ${TEMP_FILES_PATH}/realm_details.json | jq -r '.client[] | select(.name=='\"${clientname}\"')' | jq -r '.webOriginUrl'`

  client_json=$(cat <<-END
{
    "id": "`cat /proc/sys/kernel/random/uuid`",
    "clientId": "${clientname}",
    "name": "${clientname}",
    "rootUrl": "${ROOT_URL}",
    "adminUrl": "${ADMIN_URL}",
    "surrogateAuthRequired": false,
    "enabled": true,
    "alwaysDisplayInConsole": false,
    "clientAuthenticatorType": "client-secret",
    "redirectUris": [
      "${REDIRECT_URL}"
    ],
    "webOrigins": [
      "${WEBORIGIN_URL}"
    ],
    "notBefore": 0,
    "bearerOnly": false,
    "consentRequired": false,
    "standardFlowEnabled": true,
    "implicitFlowEnabled": false,
    "directAccessGrantsEnabled": true,
    "serviceAccountsEnabled": false,
    "publicClient": true,
    "frontchannelLogout": false,
    "protocol": "openid-connect",
    "attributes": {
      "saml.force.post.binding": "false",
      "saml.multivalued.roles": "false",
      "frontchannel.logout.session.required": "false",
      "oauth2.device.authorization.grant.enabled": "false",
      "backchannel.logout.revoke.offline.tokens": "false",
      "saml.server.signature.keyinfo.ext": "false",
      "use.refresh.tokens": "true",
      "oidc.ciba.grant.enabled": "false",
      "backchannel.logout.session.required": "true",
      "client_credentials.use_refresh_token": "false",
      "require.pushed.authorization.requests": "false",
      "saml.client.signature": "false",
      "saml.allow.ecp.flow": "false",
      "id.token.as.detached.signature": "false",
      "saml.assertion.signature": "false",
      "saml.encrypt": "false",
      "login_theme": "mobileum",
      "saml.server.signature": "false",
      "exclude.session.state.from.auth.response": "false",
      "saml.artifact.binding": "false",
      "saml_force_name_id_format": "false",
      "acr.loa.map": "{}",
      "tls.client.certificate.bound.access.tokens": "false",
      "saml.authnstatement": "false",
      "display.on.consent.screen": "false",
      "token.response.type.bearer.lower-case": "false",
      "saml.onetimeuse.condition": "false"
    },
    "authenticationFlowBindingOverrides": {},
    "fullScopeAllowed": true,
    "nodeReRegistrationTimeout": -1,
    "protocolMappers": [
      {
        "id": "`cat /proc/sys/kernel/random/uuid`",
        "name": "realm roles",
        "protocol": "openid-connect",
        "protocolMapper": "oidc-usermodel-realm-role-mapper",
        "consentRequired": false,
        "config": {
          "multivalued": "true",
          "userinfo.token.claim": "true",
          "user.attribute": "foo",
          "id.token.claim": "true",
          "access.token.claim": "true",
          "claim.name": "roles",
          "jsonType.label": "String"
        }
      },
      {
        "id": "`cat /proc/sys/kernel/random/uuid`",
        "name": "groups",
        "protocol": "openid-connect",
        "protocolMapper": "oidc-usermodel-realm-role-mapper",
        "consentRequired": false,
        "config": {
          "multivalued": "true",
          "user.attribute": "foo",
          "id.token.claim": "true",
          "access.token.claim": "true",
          "claim.name": "groups",
          "jsonType.label": "String"
        }
      },
      {
        "id": "`cat /proc/sys/kernel/random/uuid`",
        "name": "${clientname}-audiance",
        "protocol": "openid-connect",
        "protocolMapper": "oidc-audience-mapper",
        "consentRequired": false,
        "config": {
          "included.client.audience": "${clientname}",
          "id.token.claim": "true",
          "access.token.claim": "true"
        }
      },
      {
        "id": "`cat /proc/sys/kernel/random/uuid`",
        "name": "client roles",
        "protocol": "openid-connect",
        "protocolMapper": "oidc-usermodel-client-role-mapper",
        "consentRequired": false,
        "config": {
          "user.attribute": "foo",
          "access.token.claim": "true",
          "claim.name": "resource_access..roles",
          "jsonType.label": "String",
          "multivalued": "true"
        }
      }
    ],
    "defaultClientScopes": [
      "web-origins",
      "acr",
      "profile",
      "roles",
      "email"
    ],
    "optionalClientScopes": [
      "address",
      "phone",
      "offline_access",
      "microprofile-jwt"
    ]
} 
END
)
  if [ ! -f ${TEMP_FILES_PATH}/client.json ]
  then
    echo ["${client_json}" > ${TEMP_FILES_PATH}/client.json
  else
    echo ,"${client_json}" >> ${TEMP_FILES_PATH}/client.json
  fi
done
echo ] >> ${TEMP_FILES_PATH}/client.json

#### prepare role ###
cat ${TEMP_FILES_PATH}/realm_details.json | jq -r '.roles[]' | while read rolename ; do
  role_json=$(cat  <<-END
{
    "id": "`cat /proc/sys/kernel/random/uuid`",
    "name": "$rolename",
    "description": "${role_admin}",
    "composite": false,
    "clientRole": false,
    "containerId": "mobileum",
    "attributes": {}
}
END
)
  if [ ! -f ${TEMP_FILES_PATH}/role.json ]
  then
    echo ["${role_json}" > ${TEMP_FILES_PATH}/role.json
  else
    echo ,"${role_json}" >> ${TEMP_FILES_PATH}/role.json
  fi
done
echo ] >> ${TEMP_FILES_PATH}/role.json

#### prepare group ###
cat ${TEMP_FILES_PATH}/realm_details.json | jq -r '.groups[].name' | while read grp ; do

  realm_roles=`cat ${TEMP_FILES_PATH}/realm_details.json | jq -r '.groups[] | select(.name=='\"${grp}\"') | .roles | join(",")' | jq -cR '. | gsub("^ +| +$"; "") | split(" *, *"; "")'`
  groups_json=$(cat <<-END
{
    "id": "`cat /proc/sys/kernel/random/uuid`",
    "name": "${grp}",
    "path": "/${grp}",
    "attributes": {},
    "realmRoles": ${realm_roles},
    "clientRoles": {},
    "subGroups": []
}
END
)
  if [ ! -f ${TEMP_FILES_PATH}/groups.json ]
  then
    echo ["${groups_json}" > ${TEMP_FILES_PATH}/groups.json
  else
    echo ,"${groups_json}" >> ${TEMP_FILES_PATH}/groups.json
  fi
done
echo ] >> ${TEMP_FILES_PATH}/groups.json

#### prepare users ###
cat ${TEMP_FILES_PATH}/realm_details.json | jq -r '.usernames[].name' | while read usr ; do
  
  user_relm_roles=`cat ${TEMP_FILES_PATH}/realm_details.json | jq -r '.usernames[] | select(.name=='\"${usr}\"') | .roles | join(",")' | jq -cR '. | gsub("^ +| +$"; "") | split(" *, *"; "")'`
  user_groups=`cat ${TEMP_FILES_PATH}/realm_details.json | jq -r '.usernames[] | select(.name=='\"${usr}\"') | .groups | join(",")' | jq -cR '. | gsub("^ +| +$"; "") | split(" *, *"; "")'`
  
  users_json=$(cat <<-END
{
    "id" : "`cat /proc/sys/kernel/random/uuid`",
    "createdTimestamp" : 1654013022392,
    "username" : "${usr}",
    "enabled" : true,
    "totp" : false,
    "emailVerified" : true,
    "firstName" : "${usr}",
    "email" : "${usr}@mobileum.com",
    "credentials" : [ {
      "id" : "`cat /proc/sys/kernel/random/uuid`",
      "type" : "password",
      "createdDate" : 1654013036184,
      "secretData" : "{\"value\":\"UsKAhMJtom6iw6vtMcMmJYIUqafeauEd6gaBKpJXByIc7SkJxJACkNlKOAEFci6cnoxU9jUPLATLk+PMno143g==\",\"salt\":\"kAzT9d8gCl6l5DjQ+D8Vlw==\",\"additionalParameters\":{}}",
      "credentialData" : "{\"hashIterations\":27500,\"algorithm\":\"pbkdf2-sha256\",\"additionalParameters\":{}}"
    } ],
    "disableableCredentialTypes" : [ ],
    "requiredActions" : [ ],
    "realmRoles" : ${user_relm_roles},
    "notBefore" : 0,
    "groups" : ${user_groups}
}
END
)
  if [ ! -f ${TEMP_FILES_PATH}/users.json ]
  then
    echo ["${users_json}" > ${TEMP_FILES_PATH}/users.json
  else
    echo ,"${users_json}" >> ${TEMP_FILES_PATH}/users.json
  fi
done
echo ] >> ${TEMP_FILES_PATH}/users.json

jq --argjson realmInfo "$(cat ${TEMP_FILES_PATH}/role.json)" '.roles.realm += $realmInfo' ${COMMON_REALM_APTH}/realm-template.json > ${TEMP_FILES_PATH}/with_role.json
jq --argjson clientInfo "$(cat ${TEMP_FILES_PATH}/client.json)" '.clients += $clientInfo' ${TEMP_FILES_PATH}/with_role.json > ${TEMP_FILES_PATH}/with_client.json
jq --argjson groupInfo "$(cat ${TEMP_FILES_PATH}/groups.json)" '.groups += $groupInfo' ${TEMP_FILES_PATH}/with_client.json > ${TEMP_FILES_PATH}/with_groups.json
jq --argjson userInfo "$(cat ${TEMP_FILES_PATH}/users.json)" '.users += $userInfo' ${TEMP_FILES_PATH}/with_groups.json > ${TEMP_FILES_PATH}/realm_export.json

cp -r ${TEMP_FILES_PATH}/realm_export.json ${EXPORT_REALM_PATH}

rm -rf ${TEMP_FILES_PATH}/client.json ${TEMP_FILES_PATH}/role.json ${TEMP_FILES_PATH}/groups.json ${TEMP_FILES_PATH}/users.json 
rm -rf ${TEMP_FILES_PATH}/with_role.json ${TEMP_FILES_PATH}/with_client.json ${TEMP_FILES_PATH}/with_groups.json
rm -rf ${TEMP_FILES_PATH}/realm_details.json
fi