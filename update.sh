#!/bin/bash
set -exuo pipefail

cd "$(dirname "$0")"
mkdir -p 'data/'

CURL="curl --no-progress-meter --location --fail"

for f in 'named.root' 'root.zone'; do
  $CURL -o "data/${f}" "https://www.internic.net/domain/${f}"
done

mkdir -p 'data/trust-anchors/'
for f in 'checksums-sha256.txt' 'icannbundle.pem' 'root-anchors.p7s' 'root-anchors.xml'; do
  $CURL -o "data/trust-anchors/${f}" "https://data.iana.org/root-anchors/${f}"
done

$CURL -o 'data/tlds-alpha-by-domain.txt' 'https://data.iana.org/TLD/tlds-alpha-by-domain.txt'

# Create file "root-without-generated.zone" excluded SOA serial number and generated records (RRSIG, NSEC, ZONEMD)
awk '$4 == "SOA" { print gensub (/\S+/, "1", 7); next } $4 != "NSEC" && $4 != "ZONEMD" && $4 != "RRSIG"' 'data/root.zone' > 'data/root-without-generated.zone'
