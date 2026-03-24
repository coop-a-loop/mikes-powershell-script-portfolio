body = @{
    grant_type = "client_credentials"
    client_id = "<insert client id>"
    client_secret = "<insert client secret>"
    scope = "monitoring management"
    }
    
    #What instance of Ninja are you hosted on?
    $NinjaURL = 'https://app.ninjarmm.com'

    $API_AuthHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $API_AuthHeaders.Add("accept", 'application/json')
    $API_AuthHeaders.Add("Content-Type", 'application/x-www-form-urlencoded')
    
    $auth_token = Invoke-RestMethod -Uri "$($NinjaURL)/oauth/token" -Method POST -Headers $API_AuthHeaders -Body $body
    $access_token = $auth_token | Select-Object -ExpandProperty 'access_token' -EA 0
    
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("accept", 'application/json')
    $headers.Add("Authorization", "Bearer $access_token")
    
    $organizations_url = "$($NinjaURL)/v2/organizations"
    $organizations = Invoke-RestMethod -Uri $organizations_url -Method GET -Headers $headers

    $locations_url = "$($NinjaURL)/v2/locations"
    $locations = Invoke-RestMethod -Uri $locations_url -Method GET -Headers $headers

foreach ($organization in $organizations)
  {
        $org_gcf_url = "$($NinjaURL)/v2/organization/" + $organization.id + "/custom-fields"
        $org_gcf = Invoke-Restmethod -Uri $org_gcf_url -method GET -Headers $headers
        if ($org_gcf.dtcOrgGuid -eq $null)
          {
            Write-Host "Org Name: $($organization.name)"
            Write-Host "Org ID: $($organization.id)"
            
            # Generate a new GUID in all caps if dtcOrgGuid value is null
            $newOrgGuid = [Guid]::NewGuid().ToString().ToUpper()

            $request_body = @{
                  dtcOrgGuid = $newOrgGuid
                }

            #convert body to JSON
            $json = $request_body | ConvertTo-Json

            #update the DTC Location GUID
            Invoke-RestMethod -Method 'Patch' -Uri $org_gcf_url -Headers $headers -Body $json -ContentType "application/json" -Verbose

            Write-Host "    Added unique all caps DTC Org GUID: $($newOrgGuid)"
            Write-Host "`n"
          }
        else
          {
            #check if org Guid contains any lower case characters
            if ($org_gcf.dtcOrgGuid -cmatch "[a-z]")
              {
                Write-Host "Org Name: $($organization.name)"
                Write-Host "Org ID: $($organization.id)"
                Write-Host "    DTC Organization GUID contains lower case - $($org_gcf.dtcOrgGuid)"
              
                #convert lower case org GUID to upper case
                $upperGuid = $org_gcf.dtcOrgGuid.toUpper()
            
                $allcaps_request_body = @{
                  dtcOrgGuid = $upperGuid
                }

                #convert body to JSON
                $json2 = $allcaps_request_body | ConvertTo-Json

                #update the DTC Org GUID
                Invoke-RestMethod -Method 'Patch' -Uri $org_gcf_url -Headers $headers -Body $json2 -ContentType "application/json" -Verbose

                Write-Host "    DTC Organization GUID updated to all caps - $($upperGuid)"
                Write-Host "`n"
              }
          }
        foreach ($location in $locations)
          {
            if ($location.organizationId -eq $organization.id)
              {
                $gcf_url = "$($NinjaURL)/v2/organization/" + $organization.id + "/location/" + $location.id + "/custom-fields"
                $gcfs = Invoke-RestMethod -Uri $gcf_url -Method GET -Headers $headers
                foreach ($gcf in $gcfs)
                  {
                    if ($gcf.dtcLocationGuid -eq $null)
                      {
                        Write-Host "Org Name: $($organization.name)"
                        Write-Host "Org ID: $($organization.id)"
                        Write-Host "  Location Name: $($location.name) - Location ID: $($location.id)"

                        # Generate a new GUID in all caps if dtcLocationGuid value is null
                        $newGuid = [Guid]::NewGuid().ToString().ToUpper()
                
                        $request_body = @{
                        dtcLocationGuid = $newGuid
                        }

                        #convert body to JSON
                        $json = $request_body | ConvertTo-Json

                        #update the DTC Location GUID
                        Invoke-RestMethod -Method 'Patch' -Uri $gcf_url -Headers $headers -Body $json -ContentType "application/json" -Verbose

                        Write-Host "    Added unique all caps DTC Location GUID: $($newGuid)"
                        Write-Host "`n"
                      }
                    else
                      {
                        #check if location Guid contains any lower case characters
                        if ($gcf.dtcLocationGuid -cmatch "[a-z]")
                          {
                            Write-Host "Org Name: $($organization.name)"
                            Write-Host "Org ID: $($organization.id)"
                            Write-Host "    DTC Location GUID contains lower case - $($gcf.dtcLocationGuid)"
                  
                            #convert lower case location GUID to upper case
                            $upperGuid = $gcf.dtcLocationGuid.toUpper()

                            $allcaps_request_body = @{
                              dtcLocationGuid = $upperGuid
                            }

                            #convert body to JSON
                            $json2 = $allcaps_request_body | ConvertTo-Json

                            #update the DTC Location GUID
                            Invoke-RestMethod -Method 'Patch' -Uri $gcf_url -Headers $headers -Body $json2 -ContentType "application/json" -Verbose

                            Write-Host "    DTC Location GUID updated to all caps - $($upperGuid)"
                            Write-Host "`n"
                          }
                      }  
                  } 
              }   
          }
  }
Write-Host "Processing Complete"
