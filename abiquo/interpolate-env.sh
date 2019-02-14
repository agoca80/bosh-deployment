#!/bin/bash

source "$1"

set -eu -o pipefail

bosh_deployment="$(cd "$(dirname "${BASH_SOURCE[0]}")"; cd ..; pwd)"
bosh_deployment_sha="$(cd "${bosh_deployment}"; git rev-parse --short HEAD)"

bosh int "${bosh_deployment}/bosh.yml" \
  --ops-file "${bosh_deployment}/abiquo/cpi.yml" \
  --ops-file "${bosh_deployment}/bosh-abiquo.yml" \
  --ops-file "${bosh_deployment}/uaa.yml" \
  --ops-file "${bosh_deployment}/credhub.yml" \
  --ops-file "${bosh_deployment}/jumpbox-user.yml" \
  --var outbound_network_name=NatNetwork \
  --var abiquo_datacenterrepository="${abiquo_datacenterrepository}" \
  --var abiquo_virtualdatacenter="${abiquo_virtualdatacenter}" \
  --var abiquo_virtualappliance="${abiquo_virtualappliance}" \
  --var abiquo_externalnetwork="${abiquo_externalnetwork}" \
  --var abiquo_stemcell="${abiquo_stemcell}" \
  --var abiquo_username="${abiquo_username}" \
  --var abiquo_password="${abiquo_password}" \
  --var abiquo_endpoint="${abiquo_endpoint}" \
  --var internal_cidr=10.60.13.0/24 \
  --var internal_ip=10.60.13.253  \
  --var internal_gw=10.60.13.1    \
  --var director_name=bosh-abiquo \
  --vars-store "${PWD}/creds.yml-ign"

