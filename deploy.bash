#!/usr/bin/env bash
set -e -o pipefail +x
trap cleanup EXIT
function cleanup() {
    echo "Script Over"
}
function cfStopApp() {
    echo "Stopping Apps"
    echo "Stopping " $1
    app=$1
    if [ ! -z $(cf apps | grep "${app}" | grep started | awk '{print $1}' | head -n 1) ];
    then
        stopActual=$(cf apps | grep "${app}" | grep started | awk '{print $1}' | head -n 1)
        echo "inside if"
        echo $stopActual
        cf stop "${stopActual}" || true
    fi
    echo "Apps Stopped"
}
function cfDownloadArtifacts() {
    rm -rf *.jar
    rm -rf *.tar.gz
    rm -rf *.yml
    echo "downloading artifacts"
    echo ""
    artifact_url="https://pcf-deploy.artifactory.homedepot.com/artifactory/pcf-deploy/com/homedepot/CIM_Releases/2018_02_07_2/${vChgnbr}_${vAppname}.tar.gz"
    echo "downloading ${artifact_url}"
    curl --fail --retry 3 --url "${artifact_url}" | tar xzvf -
    echo ""
    ls -ltr
}
function cfPushApp() {
    echo "Pushing $vAppname"
    cd ${vChgnbr}_${vAppname}
    cf push -p "$vAppname.jar" -f "$vAppname.manifest.yml"
    cd ..
    echo $vAppname
    echo "App Pushed"
}
function cfGetVars(){
    zoneA="a"
    zoneB="b"
    zoneNP="np"
    #zoneHotHot="hothot"
    printf 'Please give name of the zone you need to deploy (a/b/np): '
    read vZone
    #printf 'Please enter the username: '
    #read vUserName
    #printf 'Please enter the password: '
    #read -s vPassword
    echo $vZone
    #echo $vUserName
}
function cfDeleteApps() {
    echo "Deleting Apps"
    echo "Deleting " $1
    deleteApp=$1
    if [ ! -z $(cf apps | grep "${deleteApp}" | grep stopped | awk '{print $1}' | head -n 1) ];
    then
        deleteActual=$(cf apps | grep "${deleteApp}" | grep stopped | awk '{print $1}' | head -n 1)
        echo "inside delete if"
        echo $deleteActual
        cf delete -f "${deleteActual}" || true
    fi
    echo "App Deleted"
}
function cfRenameApps() {
    echo "Renaming Apps"
    echo "Renaming " $1
    renameApp=$1
    if [ ! -z $(cf apps | grep "${renameApp}" | grep stopped | awk '{print $1}' | head -n 1) ];
    then
        renameActual=$(cf apps | grep "${renameApp}" | grep stopped | awk '{print $1}' | head -n 1)
        echo "inside rename if"
        echo $renameActual
        cf rename "${renameActual}" cim-${vAppname}_old || true
    fi
    echo "App Renamed"
}
function cfLoginZoneA() {
    echo "executing zoneA login command"
    #cf login -a https://api.run-za.homedepot.com -u $vUserName -p $vPassword
}
function cfLoginZoneB() {
    echo "executing zoneB login command"
    #cf login -a https://api.run-zb.homedepot.com -u $vUserName -p $vPassword
}
function cfLoginZoneNP() {
    echo "executing zone np login command and switching to org cim and space dev"
    #cf login -a https://api.run-np.homedepot.com -u $vUserName -p $vPassword
    #cf target -o cim -s dev
}
APPS=(
"CHG0327687"
"DeliveryData"
"cim-DeliveryData"
"CHG0327688"
"DeliveryImport"
"cim-DeliveryImport"
"CHG0327694"
"DeliveryJobsManager"
"cim-DeliveryJobsManager"
"CHG0327689"
"DeliveryMarketLevelReport"
"cim-DeliveryMarketLevelReport"
"CHG0327695"
"ShipTypeDeterminationService"
"cim-ShipTypeDeterminationService"
"CHG0327696"
"KeyRecPoLookup"
"cim-KeyRecPoLookup"
"CHG0327690"
"CarrierLookup"
"cim-CarrierLookup"
"CHG0327692"
"ContentManager"
"cim-ContentManager"
"CHG0327926"
"TMSFacilityLookup"
"cim-TMSFacilityLookup"
"CHG0327932"
"TMSFuelService"
"cim-TMSFuelService"
"CHG0327941"
"TMSRatingService"
"cim-TMSRatingService"
"CHG0328015"
"InvoiceAllocationService"
"cim-InvoiceAllocationService"
)
function zoneMapping() {
    echo "mapping routes for zone "
    cf map-route cim-${vAppname} apps.homedepot.com --hostname cim-${vAppname}
}
function triggerDeployment() {
    echo "Deployment process started"+${vAppname}
    echo "Change Number"+${vChgnbr}
    cfDownloadArtifacts
    cfStopApp "$vPreviousAppname"
    cfDeleteApps "cim-${vAppname}_old"
    cfRenameApps "$vPreviousAppname"
    cfPushApp
    if [ "$vZone" != "$zoneNP" ];
    then
        zoneMapping
    fi
}
function doDeployment() {
    arraylength=${#APPS[@]}
    # use for loop to read all values and indexes
        for (( i=0; i<${arraylength}; i=i+3 ));
        do
            vChgnbr=${APPS[$i]}
            echo $vChgnbr
            vAppname=${APPS[$i+1]}
            echo $vAppname
            vPreviousAppname=${APPS[$i+2]}
            echo $vPreviousAppname
            if [ "$vZone" == "$zoneA" ];
            then
                echo "running commands for login and curl on zone A"
                #cfLoginZoneA
                triggerDeployment
            fi
            if [ "$vZone" == "$zoneB" ];
            then
                echo "running commands for login and curl on zone B"
                #cfLoginZoneB
                triggerDeployment
            fi
            #if [ "$vZone" == "$zoneHotHot" ];
            #then
            #   echo "running commands for login and curl on zone A"
                #cfLoginZoneA
            #   triggerDeployment
            #   echo "running commands for login and curl on zone B"
                #cfLoginZoneB
            #   triggerDeployment
            #fi
            if [ "$vZone" == "$zoneNP" ];
            then
                echo "running commands for login on zone np"
                #cfLoginZoneNP
                triggerDeployment
            fi
            if [ "$vZone" == "$zoneNP" ];
            then
                echo "no mapping routes in zone np"
            fi
        done
}
cfGetVars
doDeployment
echo "mapping complete"
echo ""
echo "Applications Deployed Successfully"
echo ""
