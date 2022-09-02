Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
Connect-AzureAD

$flows = Get-AdminFlow
$enrichedData = @()
foreach($flow in $flows){
    $UPN = $null
    try{
        $AADUser = Get-AzureADUser -ObjectId $flow.CreatedBy.ObjectId
        $UPN = $AADUser.UserPrincipalName
    }
    catch{
        $UPN = "None"
    }

    #Need to retrieve additional details for the Connector Overview
    $flowDetails = Get-AdminFlow -FlowName $flow.FlowName -EnvironmentName $flow.EnvironmentName

    $Environment = Get-AdminPowerAppEnvironment $flow.EnvironmentName

    $connectors = $flowDetails.Internal.properties.connectionReferences
    $connectorOverview = ''
    $connectors.PSObject.Properties | ForEach-Object {
         $connectorOverview += $_.Value.DisplayName + ","
    }

    $enrichedData += [PSCustomObject]@{
        Creator = $AADUser.UserPrincipalName
        Name = $flow.DisplayName
        ID = $flow.FlowName
        State = $flow.Enabled
        CreatedTime = $flow.CreatedTime
        Environment = $Environment.DisplayName
        Connectors = $connectorOverview
    }
}

$enrichedData | Select-Object Creator, ID, State, Name, CreatedTime, Environment, Connectors| Export-csv -notypeinformation -path "C:\temp\flows.csv"
