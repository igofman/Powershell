﻿Add-Type -assembly "Microsoft.Office.Interop.Outlook"
$Outlook = New-Object -com Outlook.Application 
$Namespace = $outlook.GetNamespace("MAPI") 

$FolderSource = @($Namespace.Folders)

function Get-OutlookSubFolder($FolderSource) {
    foreach ($Folder in $FolderSource.Folders) {
        #New-Object psobject -Property @{'FullPath' = $Folder.FolderPath; 'FolderName' = $Folder.Name; 'Folder' = $Folder; 'Folders' = $Folder.Folders }
        $Folder
        Get-OutlookSubFolder $Folder
    }
}

Get-OutlookSubFolder($Namespace) | Select Name
