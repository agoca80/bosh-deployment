#!/bin/bash

cd $HOME/bosh/abiquo

source $HOME/bosh/settings

set -eu -o pipefail

bosh_deployment="$(cd "$(dirname "${BASH_SOURCE[0]}")"; cd ..; pwd)"
bosh_deployment_sha="$(cd "${bosh_deployment}"; git rev-parse --short HEAD)"

if [ "${PWD##${bosh_deployment}}" != "${PWD}" ] || [ -e abiquo/create-env.sh ] || [ -e ../abiquo/create-env.sh ]; then
  echo "It looks like you are running this within the ${bosh_deployment} repository."
  echo "To avoid secrets ending up in this repo, run this from another directory."
  echo

  exit 1
fi

bosh create-env "${bosh_deployment}/bosh.yml" \
  --state "${PWD}/state.json" \
  --ops-file "${bosh_deployment}/abiquo/cpi.yml" \
  --ops-file "${bosh_deployment}/bosh-abiquo.yml" \
  --ops-file "${bosh_deployment}/uaa.yml" \
  --ops-file "${bosh_deployment}/credhub.yml" \
  --ops-file "${bosh_deployment}/jumpbox-user.yml" \
  --vars-store "${PWD}/creds.yml" \
  --var abiquo_tier="${abiquo_tier}" \
  --var abiquo_datacenterrepository="${abiquo_datacenterrepository}" \
  --var abiquo_virtualdatacenter="${abiquo_virtualdatacenter}" \
  --var abiquo_virtualappliance="${abiquo_virtualappliance}" \
  --var abiquo_externalnetwork="${abiquo_externalnetwork}" \
  --var abiquo_stemcell="${abiquo_stemcell}" \
  --var abiquo_username="${abiquo_username}" \
  --var abiquo_password="${abiquo_password}" \
  --var abiquo_endpoint="${abiquo_endpoint}" \
  --var internal_cidr="${internal_cidr}"     \
  --var internal_ip="${internal_ip}"         \
  --var internal_gw="${internal_gw}"         \
  --var director_name=bosh-abiquo2           \
  --var az=z1

cat > .envrc <<EOF
export BOSH_ENVIRONMENT=abq
export BOSH_CA_CERT=\$( bosh interpolate ${PWD}/creds.yml --path /director_ssl/ca )
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$( bosh interpolate ${PWD}/creds.yml --path /admin_password )

export CREDHUB_SERVER=https://${internal_ip}:8844
export CREDHUB_CA_CERT="\$( bosh interpolate ${PWD}/creds.yml --path=/credhub_tls/ca )
\$( bosh interpolate ${PWD}/creds.yml --path=/uaa_ssl/ca )"
export CREDHUB_CLIENT=credhub-admin
export CREDHUB_SECRET=\$( bosh interpolate ${PWD}/creds.yml --path=/credhub_admin_client_secret )

EOF
echo "export BOSH_DEPLOYMENT_SHA=${bosh_deployment_sha}" >> .envrc


source .envrc

bosh \
  --environment ${internal_ip} \
  --ca-cert <( bosh interpolate "${PWD}/creds.yml" --path /director_ssl/ca ) \
  alias-env abq


bosh -n update-cloud-config "${bosh_deployment}/abiquo/cloud-config.yml" \
  --var abiquo_tier="${abiquo_tier}" \
  --var abiquo_virtualdatacenter="${abiquo_virtualdatacenter}" \
  --var abiquo_virtualappliance="${abiquo_virtualappliance}" \
  --var abiquo_externalnetwork="${abiquo_externalnetwork}" \
  --var internal_gw="${internal_gw}"

:   source .envrc
