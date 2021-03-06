﻿function Get-DatabaseStatistics {
    # Original Script: http://mikepfeiffer.net/2010/03/exchange-2010-database-statistics-with-powershell/
    # Note: Modified to include disconnected mailbox information.
    $Databases = Get-MailboxDatabase -Status
    foreach($Database in $Databases) {
        $DBSize = $Database.DatabaseSize
        $MBCount = @(Get-MailboxStatistics -Database $Database.Name).Count
        
        $MBSizeTotal = 0
        $MBStats = Get-MailboxStatistics -Database $Database.Name
        $MBAvg = $MBStats | %{$_.TotalItemSize.value.ToMb()} | Measure-Object -Average
        $MBStats = $MBStats | %{$_.TotalItemSize.value.ToMb()} | Measure-Object
            
        $DisconnMbx = Get-MailboxStatistics -Database $Database.Name | Where { $_.DisconnectReason }
        $SoftDeleted = 0
        $SoftDeletedCount = 0
        $Disabled = 0
        $DisabledCount = 0
        Foreach ($mbx in $DisconnMbx) {
            switch ($mbx.DisconnectReason) {
                'SoftDeleted' { 
                    $SoftDeleted += $mbx.TotalItemSize.value.ToGb() 
                    $SoftDeletedCount++
                }
                'Disabled' { 
                    $Disabled += $mbx.TotalItemSize.value.ToGb()
                    $DisabledCount++
                }
            }
        }
        New-Object PSObject -Property @{
            Server = $Database.Server.Name
            DatabaseName = $Database.Name
            LastFullBackup = $Database.LastFullBackup
            MailboxCount = $MBCount
            'Soft Deleted Mailbox Count' = $SoftDeletedCount
            'Soft Deleted Mailboxes (GB)' = $SoftDeleted
            'Disabled Mailboxe Count' = $DisabledCount
            'Disabled Mailboxes (GB)' = $Disabled
            'DatabaseSize (GB)' = $DBSize.ToGB()
            'AverageMailboxSize (MB)' = [math]::Round($($MBAvg.Average),2)
            'WhiteSpace (GB)' = $Database.AvailableNewMailboxSpace.ToGb()
        }
    }
}
