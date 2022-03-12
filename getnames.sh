#!/bin/bash
set +o posix
set -e -o pipefail +x
trap cleanup EXIT

function cleanup() {
    echo "Script Over"
}
function getfiles(){
  curl -s user doc_cimreporting:zrKq9zrgGqSyW9a45VjCS6SjVLXYcEQKMXRC5DOBxLk= https://content.homedepot.com/TMSUpgrade/Contents/Stargate/CarrierInvoice_Error/{$foldername}/ --list-only | grep -o 'href="[^"]*' | tail -c +7|grep -o '0[^"]*' > list.txt
}
function downloadfiles(){
input="list.txt"
while IFS= read -r line
do
  curl -O --user doc_cimreporting:zrKq9zrgGqSyW9a45VjCS6SjVLXYcEQKMXRC5DOBxLk= https://content.homedepot.com/TMSUpgrade/Contents/Stargate/CarrierInvoice_Error/${foldername}/{$line}
done < "$input"
}
function callcim210(){
input="list.txt"
while IFS= read -r line
do
  cat $line | curl -X POST -H "Content-Type: text/xml" -d @-   https://cim210process.apps.homedepot.com/v1/invoices/process
done < "$input"
}
read -p 'foldername: ' foldername
getfiles
downloadfiles
callcim210
echo " processed files from"
echo $foldername
cleanup
