$farms = @('example.com')

ForEach($farm in $farms)
{   
    # Create the farm
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "webFarms" -name "." -value @{name=$($farm)}

    # Add server to farm
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "webFarms/webFarm[@name='$farm']" -name "." -value @{address=$farm}

    # Create rule
    $rulename = 'ARR_'+$farm+'_loadbalance_SSL'
    Write-Output $rulename

    #URL Rewrite SSL
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/rewrite/globalRules" -name "." -value @{name=$rulename;patternSyntax='Wildcard';stopProcessing='True'}
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/rewrite/globalRules/rule[@name='$rulename']/match" -name "url" -value "*"
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/rewrite/globalRules/rule[@name='$rulename']/action" -name "type" -value "Rewrite"
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/rewrite/globalRules/rule[@name='$rulename']/action" -name "url" -value "https://$farm/{R:0}"
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/rewrite/globalRules/rule[@name='ARR_$($farm)_loadbalance_SSL']/conditions" -name "." -value @{input='{HTTP_HOST}';pattern='*'+$($farm)+'*'}
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/rewrite/globalRules/rule[@name='ARR_$($farm)_loadbalance_SSL']/conditions" -name "." -value @{input='{HTTPS}';pattern='on'}

    $rulename = 'ARR_'+$farm+'_loadbalance'
    Write-Output $rulename

    # URL Rewrite
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/rewrite/globalRules" -name "." -value @{name=$rulename;patternSyntax='Wildcard';stopProcessing='True'}
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/rewrite/globalRules/rule[@name='$rulename']/match" -name "url" -value "*"
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/rewrite/globalRules/rule[@name='$rulename']/action" -name "type" -value "Rewrite"
    Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/rewrite/globalRules/rule[@name='$rulename']/action" -name "url" -value "http://$farm/{R:0}"
    Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/rewrite/globalRules/rule[@name='ARR_$($farm)_loadbalance']/conditions" -name "." -value @{input='{HTTP_HOST}';pattern='*'+$($farm)+'*'}
}