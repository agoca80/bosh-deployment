#!/bin/bash -x

cd $HOME/bosh/abiquo

source $HOME/bosh/settings

set -eu -o pipefail

bosh_deployment="$(cd "$(dirname "${BASH_SOURCE[0]}")"; cd ..; pwd)"

bosh delete-env ${bosh_deployment}/bosh.yml \
  --ops-file "${bosh_deployment}/abiquo/cpi.yml" \
  --ops-file "${bosh_deployment}/bosh-abiquo.yml" \
  --ops-file "${bosh_deployment}/uaa.yml" \
  --ops-file "${bosh_deployment}/credhub.yml" \
  --ops-file "${bosh_deployment}/jumpbox-user.yml" \
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
  --var az=z1                                \
  --vars-store "${PWD}/creds.yml" \
  --state "${PWD}/state.json"
