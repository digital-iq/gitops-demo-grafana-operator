export HOME=/tmp/approver
echo "Approving operator InstallPlans. Waiting a few seconds to make sure the InstallPlan gets created first."
sleep 10
echo "Waiting is done"
for subscription in `oc get -o name subscription.operators.coreos.com/$subs`
do
    echo $subscription

    desiredcsv=$(oc get $subscription -o jsonpath='{ .spec.startingCSV }')

    echo $desiredcsv

    until [ "$(oc get installplan.operators.coreos.com --template="{{ range \$item := .items }}{{ range \$item.spec.clusterServiceVersionNames }}{{ if eq . \"$desiredcsv\"}}{{ if \$item.status }}{{ if \$item.status.phase }}{{ printf \"%s\n\" \$item.metadata.name }}{{end}}{{end}}{{end}}{{end}}{{end}}")" != "" ]; do sleep 2; done
    installplans=$(oc get installplan.operators.coreos.com --template="{{ range \$item := .items }}{{ range \$item.spec.clusterServiceVersionNames }}{{ if eq . \"$desiredcsv\"}}{{ if \$item.status }}{{ if \$item.status.phase }}{{ printf \"%s\n\" \$item.metadata.name }}{{end}}{{end}}{{end}}{{end}}{{end}}")
    for installplan in $installplans
    do
        echo $installplan
        if [ "`oc get installplan.operators.coreos.com $installplan -o jsonpath="{.spec.approved}"`" == "false" ]; then
        echo "Approving Subscription $subscription with install plan $installplan"
        oc patch installplan.operators.coreos.com $installplan --type=json -p='[{"op":"replace","path": "/spec/approved", "value": true}]'
        else
        echo "Install Plan '$installplan' already approved"
        fi
    done
done
