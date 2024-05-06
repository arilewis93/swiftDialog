#!/bin/bash

# create a policy to run on enrollment completion to install a pkg (swiftDialog) and run this script.

# create json file
jsonFile=/var/tmp/swift.json

cat << EOF > $jsonFile
{
  "title": "Welcome Core Group Automated Onboarding.",
  "message": "Your computer setup is underway. Feel free to step away, but this should not take long.",
  "blurscreen": true,
  "moveable": false,
  "ontop": true,
  "width": "800",
  "icon": "/Applications/Company Portal.app",
  "centreicon": false,
  "iconsize": "100",
  "listitem": [
    {"title": "SentinelOne", "icon": "/Applications/SentinelOne/SentinelOne Extensions.app", "status": "pending", "statustext": "Pending"},
    {"title": "Company Portal", "icon": "/Applications/Company Portal.app", "status": "pending", "statustext": "Pending"}
  ]
}
EOF

# run SwiftDialog with initial look as the JSON
dialog --jsonfile /var/tmp/swift.json --button1disabled & sleep 1

# install EDR via Jamf
echo "listitem: title: SentinelOne, status: wait, statustext: Initializing..." >> /var/tmp/dialog.log
jamf policy -event edr &
edrPid=$!
echo "listitem: title: SentinelOne, status: wait, statustext: Installing..." >> /var/tmp/dialog.log

# install Company Portal via Jamf
echo "listitem: title: Company Portal, status: wait, statustext: Initializing..." >> /var/tmp/dialog.log
jamf policy -event companyportal &
companyPortalPid=$!
echo "listitem: title: Company Portal, status: wait, statustext: Installing..." >> /var/tmp/dialog.log

# Wait until both processes finish
wait $edrPid; [[ -d "/Applications/SentinelOne/SentinelOne Extensions.app" ]] && echo "listitem: title: SentinelOne, status: success, statustext: Complete" >> /var/tmp/dialog.log || echo "listitem: title: SentinelOne, status: fail, statustext: Failed" >> /var/tmp/dialog.log
wait $companyPortalPid; [[ -d "/Applications/Company Portal.app" ]] && echo "listitem: title: Company Portal, status: success, statustext: Complete" >> /var/tmp/dialog.log || echo "listitem: title: Company Portal, status: fail, statustext: Failed" >> /var/tmp/dialog.log

# Enable OK button to close SwiftDialog
echo "button1: enable" >> /var/tmp/dialog.log
