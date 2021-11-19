[CmdletBinding(DefaultParameterSetName='All')]
param (
  [Parameter(ParameterSetName='All')]
  [String]$SenderAddress,

  [Parameter(ParameterSetName='All')]
  [String]$RecipientAddress,

  [Parameter(ParameterSetName='Message', Mandatory=$true)]
  [String]$MessageId,

  [Parameter()]
  [Alias('FT')]
  [Switch]$FormatTable,

  [Parameter()]
  [DateTime]$StartDate = ((Get-Date).AddDays(-1)),

  [Parameter()]
  [DateTime]$EndDate = ((Get-Date).AddDays(1))
)

process {
  if ($FormatTable) {
    $Format = @{
      Begin = { $Acumulator = @()}
      Process = { $Acumulator += $_ }
      End = { $Acumulator | Format-Table }
    }
  } else {
    $Format = @{
      Process = { $_ }
    }
  }

  $Params = @{
    StartDate = $StartDate
    EndDate = $EndDate
  }

  switch ($PsCmdlet.ParameterSetName) {
    'All' {
      if ($SenderAddress) { $Params.SenderAddress = $SenderAddress }
      if ($RecipientAddress) { $Params.RecipientAddress = $RecipientAddress }
      Get-MessageTrace @Params
      | Sort-Object -Property Received
      | Select-Object -Property Received,SenderAddress,RecipientAddress,Status,MessageId,Subject
      | ForEach-Object @Format
    }
    'Message' {
      $Params.MessageId = $MessageId
      Get-MessageTrace @Params
      | Sort-Object -Property Received
      | ForEach-Object {
        $_ | Select-Object -Property Received,SenderAddress,RecipientAddress,Status,MessageId,Subject | ForEach-Object @Format
        $_ | Get-MessageTraceDetail | Sort-Object -Property Timestamp | ForEach-Object @Format
      }
    }
  }
}
