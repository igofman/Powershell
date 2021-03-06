﻿function ConvertTo-JSArray {
    <#
    .SYNOPSIS
    Convert a psobject to a javascript array.
    .DESCRIPTION
    Convert a psobject's noteproperties to a javascript array.
    .PARAMETER inputObject
    Array of psobjects to convert to javascript array.
    .PARAMETER IncludeHeader
    Include the header row in output.
    .EXAMPLE
    <Placeholder>
    Description
    -----------
    <Placeholder>
    .NOTES
    Author: Zachary Loeber
    Site: the-little-things.net
    #> 
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [PSObject[]]$InputObject,
        [Parameter()]
        [switch]$IncludeHeader
    )

    begin {
        #init array to dump all objects into
        $AllObjects = @()
        $jsarray = ''
        $header = ''
    }
    process {
        #if we're taking from pipeline and get more than one object, this will build up an array
        $AllObjects += $InputObject
    }
    end {
        $objcount = 0
        ForEach ($obj in $AllObjects) 
        {
            $properties = @($obj.psobject.properties | Where {$_.MemberType -eq 'NoteProperty'})
            if ($properties.Count -gt 0)
            {
                $propcount = 1
                $arrayelement = ''
                $objcount++
                ForEach($property in $properties)
                {
                    switch ($property.TypeNameOfValue)
                    {
                        'System.String' {
                            $arrayval = "'$($property.Value)'"
                        }
                        default {
                            $arrayval = $property.Value
                        }
                    }
                    # if this is not the last property then add a comma
                    if ($properties.count -ne $propcount)
                    {
                        $arrayval = "$arrayval,"
                    }
                    $arrayelement = $arrayelement+$arrayval
                    $propcount++
                }
                $arrayelement = "[$arrayelement]"
                # if this is not the last property then add a comma
                if ($AllObjects.count -ne $objcount)
                {
                    $arrayelement = "$arrayelement,"
                }
                $jsarray = $jsarray + $arrayelement
            }
        }
        if ($IncludeHeader)
        {
            $headerpropcount = 0
            $headerprops = @(($AllObjects[0]).psobject.properties | Where {$_.MemberType -eq 'NoteProperty'} | %{$_.Name})
            Foreach ($headerprop in $headerprops)
            {
                $headerpropcount++
                $header = $header + "'$headerprop'"
                # if this is will be followed by array elements then add a comma
                if (($headerpropcount -ne $headerprops.count))
                {
                    $header = "$header,"
                }
            }
            if ($jsarray -eq '')
            {
                $header = "[$header]"
            }
            else
            {
                $header = "[$header],"
            }
        }
        return "[$($header)$($jsarray)]"
    }
}
