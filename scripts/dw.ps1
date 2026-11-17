#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [ValidateSet('help','setup','import-p0','import-pack','etl','verify','backup','restore','apply-sql','build')]
    [string]$Action = 'help',
    [string]$PackPath,
    [ValidateSet('all','sales','inventory','returns')]
    [string]$Feed = 'all',
    [string]$Path,
    [string]$Name,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Data, Microsoft.VisualBasic
$Root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$EnvPath = Join-Path $Root '.env'
$ComposePath = Join-Path $Root 'docker-compose.yml'
$ProjectPath = Join-Path $Root 'RetailDW'
$P0ManifestPath = Join-Path $Root 'data/P0/manifest.json'
$ProjectName = 'nordvik-retaildw-starter'
$DatabaseName = 'RetailDW_Workshop'
$Server = '127.0.0.1'
$Password = $null
$Port = 14332

function Show-Help {
    @"
RetailDW local workshop commands (Windows PowerShell 5.1 or PowerShell 7, Docker Desktop)

  setup                  Start local SQL Server; create V0 and seed dimensions.
  import-p0              Import the three P0 CSV files into src only.
  import-pack -PackPath   Import a validated participant manifest into src only.
  etl -Feed all|sales|inventory|returns
                         Run the selected full-load procedure(s) separately.
  verify                 Print V0 objects, seed counts, data counts and latest loads.
  backup -Name p0 -Force Save a named SQL Server backup in the Docker data volume.
  restore -Name p0 -Force Replace the workshop database from a named backup.
  apply-sql -Path file.sql
                         Apply one repository SQL file, splitting on GO; :r is refused.
  build                  Optional SQL project compile check; needs .NET SDK/package access.

P0 import never runs ETL. P0 and V0 backups are kept in the Docker volume.
Restore replaces RetailDW_Workshop. Git commands do not change this database.
"@ | Write-Host
}

function Read-LocalSettings {
    if (-not (Test-Path -LiteralPath $EnvPath)) { throw 'Missing .env. Restore the workshop file from the starter package.' }
    $settings = @{}
    foreach ($line in [IO.File]::ReadAllLines($EnvPath)) {
        if ($line -match '^\s*([A-Z0-9_]+)=(.*)$') { $settings[$Matches[1]] = $Matches[2].Trim() }
    }
    if (-not $settings.ContainsKey('MSSQL_SA_PASSWORD') -or [string]::IsNullOrWhiteSpace($settings.MSSQL_SA_PASSWORD)) {
        throw 'MSSQL_SA_PASSWORD is missing from .env.'
    }
    if ($settings.MSSQL_SA_PASSWORD -match 'replace-with|your-password|CHANGE_ME') { throw 'Replace the placeholder in .env with a local workshop value.' }
    if ($settings.ContainsKey('MSSQL_PORT')) { $script:Port = [int]$settings.MSSQL_PORT }
    if ($script:Port -lt 1024 -or $script:Port -gt 65535) { throw 'MSSQL_PORT must be between 1024 and 65535.' }
    $script:Password = $settings.MSSQL_SA_PASSWORD
}

function New-SqlConnection([string]$Catalog = 'master') {
    $builder = [System.Data.SqlClient.SqlConnectionStringBuilder]::new()
    $builder['Data Source'] = "$Server,$Port"
    $builder['Initial Catalog'] = $Catalog
    $builder['User ID'] = 'sa'
    $builder['Password'] = $Password
    $builder['Encrypt'] = $false
    $builder['TrustServerCertificate'] = $true
    $builder['Connect Timeout'] = 5
    $builder['Application Name'] = 'RetailDW local workshop'
    return [System.Data.SqlClient.SqlConnection]::new($builder.ConnectionString)
}

function Invoke-Scalar([string]$Catalog, [string]$SqlText) {
    $connection = New-SqlConnection $Catalog
    try {
        $connection.Open()
        $command = $connection.CreateCommand()
        $command.CommandText = $SqlText
        $command.CommandTimeout = 120
        return $command.ExecuteScalar()
    } finally { $connection.Dispose() }
}

function Invoke-NonQuery([string]$Catalog, [string]$SqlText, [int]$Timeout = 600) {
    $connection = New-SqlConnection $Catalog
    try {
        $connection.Open()
        $command = $connection.CreateCommand()
        $command.CommandText = $SqlText
        $command.CommandTimeout = $Timeout
        [void]$command.ExecuteNonQuery()
    } finally { $connection.Dispose() }
}

function Invoke-DataTable([string]$Catalog, [string]$SqlText) {
    $connection = New-SqlConnection $Catalog
    try {
        $connection.Open()
        $command = $connection.CreateCommand()
        $command.CommandText = $SqlText
        $command.CommandTimeout = 120
        $adapter = [System.Data.SqlClient.SqlDataAdapter]::new($command)
        $table = [System.Data.DataTable]::new()
        [void]$adapter.Fill($table)
        return ,$table
    } finally { $connection.Dispose() }
}

function Resolve-RepoFile([string]$Candidate) {
    if ([string]::IsNullOrWhiteSpace($Candidate)) { throw 'A file path is required.' }
    $resolved = if ([IO.Path]::IsPathRooted($Candidate)) { [IO.Path]::GetFullPath($Candidate) } else { [IO.Path]::GetFullPath((Join-Path $Root $Candidate)) }
    $prefix = $Root.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    if (-not $resolved.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'File paths must stay inside this repository.' }
    if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) { throw "File not found inside repository: $Candidate" }
    return $resolved
}

function Invoke-SqlFile([string]$FilePath, [string]$Catalog = $DatabaseName) {
    $resolved = Resolve-RepoFile $FilePath
    if ([IO.Path]::GetExtension($resolved) -ine '.sql') { throw 'apply-sql accepts one .sql file.' }
    $lines = [IO.File]::ReadAllLines($resolved)
    $batches = [Collections.Generic.List[string]]::new()
    $builder = [Text.StringBuilder]::new()
    foreach ($line in $lines) {
        if ($line -match '^\s*:r\b|^\s*:setvar\b') { throw 'SQLCMD includes/directives such as :r are not supported.' }
        if ($line -match '^\s*GO\s*(?:--.*)?$') {
            if (-not [string]::IsNullOrWhiteSpace($builder.ToString())) { $batches.Add($builder.ToString()); [void]$builder.Clear() }
        } else { [void]$builder.AppendLine($line) }
    }
    if (-not [string]::IsNullOrWhiteSpace($builder.ToString())) { $batches.Add($builder.ToString()) }
    $connection = New-SqlConnection $Catalog
    try {
        $connection.Open()
        foreach ($batch in $batches) {
            $command = $connection.CreateCommand()
            $command.CommandText = $batch
            $command.CommandTimeout = 600
            [void]$command.ExecuteNonQuery()
            $command.Dispose()
        }
    } finally { $connection.Dispose() }
    $relative = $resolved.Substring($Root.TrimEnd([IO.Path]::DirectorySeparatorChar).Length + 1)
    Write-Host "Applied $relative to $Catalog. No ETL was run."
}

function Start-LocalSqlServer {
    Read-LocalSettings
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Docker CLI is required.' }
    # Docker writes progress to stderr; with 'Stop' Windows PowerShell 5.1 would treat it as a terminating error.
    $ErrorActionPreference = 'Continue'
    try { & docker compose --env-file $EnvPath --project-name $ProjectName --file $ComposePath up -d 2>&1 | ForEach-Object { Write-Host "$_" } }
    finally { $ErrorActionPreference = 'Stop' }
    if ($LASTEXITCODE -ne 0) { throw 'docker compose up failed.' }
    for ($i=0; $i -lt 60; $i++) {
        $connection = $null
        try {
            $connection = New-SqlConnection 'master'
            $connection.Open()
            $connection.Dispose()
            Write-Host "SQL Server is ready on 127.0.0.1:$Port."
            return
        } catch {
            if ($connection) { $connection.Dispose() }
            Start-Sleep -Seconds 2
        }
    }
    throw 'SQL Server did not become ready within 120 seconds.'
}

function Get-BackupPath([string]$BackupName) {
    if ([string]::IsNullOrWhiteSpace($BackupName) -or $BackupName -notmatch '^[A-Za-z0-9][A-Za-z0-9_-]{0,39}$') {
        throw 'Backup name may contain only letters, digits, underscore and hyphen.'
    }
    return "/var/opt/mssql/data/retaildw_workshop_$BackupName.bak"
}

function Test-BackupExists([string]$BackupName) {
    $filePath = Get-BackupPath $BackupName
    $connection = New-SqlConnection 'master'
    try {
        $connection.Open()
        $command = $connection.CreateCommand()
        $command.CommandText = 'DECLARE @exists INT=0; EXEC master.dbo.xp_fileexist @path, @exists OUTPUT; SELECT @exists;'
        [void]$command.Parameters.AddWithValue('@path', $filePath)
        return ([int]$command.ExecuteScalar() -eq 1)
    } finally { $connection.Dispose() }
}

function Save-Backup([string]$BackupName, [switch]$Overwrite) {
    $filePath = Get-BackupPath $BackupName
    $hasExisting = Test-BackupExists $BackupName
    if ($hasExisting -and -not $Overwrite.IsPresent) {
        Write-Host "Checkpoint '$BackupName' already exists; it was not overwritten. Use backup -Name $BackupName -Force to replace it."
        return $false
    }
    $sqlPath = $filePath.Replace("'", "''")
    Invoke-NonQuery 'master' "BACKUP DATABASE [$DatabaseName] TO DISK=N'$sqlPath' WITH INIT, CHECKSUM, COMPRESSION;" 1200
    Write-Host "Saved checkpoint '$BackupName' in the persistent Docker data volume."
    return $true
}

function Restore-Backup([string]$BackupName) {
    $filePath = Get-BackupPath $BackupName
    if (-not (Test-BackupExists $BackupName)) { throw "Checkpoint '$BackupName' was not found in the Docker data volume." }
    $sqlPath = $filePath.Replace("'", "''")
    Invoke-NonQuery 'master' "IF DB_ID(N'$DatabaseName') IS NOT NULL ALTER DATABASE [$DatabaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;" 1200
    try {
        Invoke-NonQuery 'master' "RESTORE DATABASE [$DatabaseName] FROM DISK=N'$sqlPath' WITH REPLACE, RECOVERY;" 1200
    } finally {
        try { Invoke-NonQuery 'master' "IF DB_ID(N'$DatabaseName') IS NOT NULL ALTER DATABASE [$DatabaseName] SET MULTI_USER;" 1200 } catch { }
    }
    Write-Host "Restored '$DatabaseName' from checkpoint '$BackupName'. The previous database state was replaced."
}

function Get-SourceTables {
    return @(
        'Tables/dbo.DimDate.sql','Tables/dbo.DimProduct.sql','Tables/dbo.DimStore.sql',
        'Tables/dbo.FactInventoryDaily.sql','Tables/dbo.FactReturns.sql','Tables/dbo.FactSales.sql','Tables/dbo.LoadLog.sql',
        'Tables/src.InventoryRaw.sql','Tables/src.ReturnsRaw.sql','Tables/src.SalesRaw.sql',
        'Tables/stg.Inventory.sql','Tables/stg.Returns.sql','Tables/stg.Sales.sql'
    )
}

function Install-V0 {
    $exists = [int](Invoke-Scalar 'master' "SELECT CASE WHEN DB_ID(N'$DatabaseName') IS NULL THEN 0 ELSE 1 END;")
    if ($exists -eq 1) {
        $tableCount = [int](Invoke-Scalar $DatabaseName 'SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped=0;')
        if ($tableCount -eq 13) {
            Write-Host "'$DatabaseName' already has the V0 table set; setup left the database unchanged."
            return
        }
        throw "'$DatabaseName' already exists but is not a complete 13-table V0. Setup did not alter it; inspect and restore a named backup deliberately."
    }
    Invoke-NonQuery 'master' "CREATE DATABASE [$DatabaseName];"
    foreach ($file in @('Security/src.sql','Security/stg.sql','Security/etl.sql','Security/reporting.sql')) {
        Invoke-SqlFile (Join-Path $ProjectPath $file)
    }
    foreach ($file in (Get-SourceTables)) { Invoke-SqlFile (Join-Path $ProjectPath $file) }
    foreach ($file in @('Procedures/etl.LoadInventory.sql','Procedures/etl.LoadReturns.sql','Procedures/etl.LoadSales.sql')) {
        Invoke-SqlFile (Join-Path $ProjectPath $file)
    }
    foreach ($file in @('Views/reporting.vw_MarginAnalysis.sql','Views/reporting.vw_ProductPerformance.sql','Views/reporting.vw_SalesDaily.sql','Views/reporting.vw_SalesWeekly.sql','Views/reporting.vw_StockAvailability.sql','Views/reporting.vw_StoreScorecard.sql')) {
        Invoke-SqlFile (Join-Path $ProjectPath $file)
    }
    foreach ($file in @('Scripts/Seed/00-DimDate.sql','Scripts/Seed/01-DimProduct.sql','Scripts/Seed/02-DimStore.sql')) {
        Invoke-SqlFile (Join-Path $ProjectPath $file)
    }
    [void](Save-Backup -BackupName 'v0')
    Write-Host 'Installed V0: 13 tables, 3 ETL procedures, 6 reporting views and 3 dimension seeds.'
    Write-Host 'No CSV was imported and no ETL procedure was run.'
}

function Get-SourceColumnMetadata([string]$Schema, [string]$Table) {
    if ($Schema -cne 'src' -or $Table -notmatch '^[A-Za-z][A-Za-z0-9_]*$') { throw 'Import targets must be simple tables in the src schema.' }
    $connection = New-SqlConnection $DatabaseName
    try {
        $connection.Open()
        $command = $connection.CreateCommand()
        $command.CommandText = @"
SELECT c.name, c.is_identity, c.is_computed
FROM sys.columns c
JOIN sys.tables t ON t.object_id=c.object_id
JOIN sys.schemas s ON s.schema_id=t.schema_id
WHERE s.name=@schema AND t.name=@table
ORDER BY c.column_id;
"@
        [void]$command.Parameters.AddWithValue('@schema', $Schema)
        [void]$command.Parameters.AddWithValue('@table', $Table)
        $adapter = [System.Data.SqlClient.SqlDataAdapter]::new($command)
        $data = [System.Data.DataTable]::new()
        [void]$adapter.Fill($data)
        if ($data.Rows.Count -eq 0) { throw "Target [src].[$Table] does not exist. Apply its SQL migration first." }
        return ,$data
    } finally { $connection.Dispose() }
}

function Read-PackManifest([string]$ManifestCandidate) {
    $manifestPath = Resolve-RepoFile $ManifestCandidate
    $raw = [IO.File]::ReadAllText($manifestPath, [Text.Encoding]::UTF8)
    $manifest = $raw | ConvertFrom-Json
    $topKeys = @($manifest.PSObject.Properties.Name)
    if (@($topKeys | Where-Object { $_ -notin @('pack','contract','files') }).Count -gt 0) { throw 'Manifest contains unsupported fields.' }
    if ([string]::IsNullOrWhiteSpace([string]$manifest.pack) -or [string]::IsNullOrWhiteSpace([string]$manifest.contract)) { throw 'Manifest must identify its pack and contract.' }
    $files = @($manifest.files)
    if ($files.Count -eq 0) { throw 'Manifest has no files.' }
    $base = Split-Path -Parent $manifestPath
    foreach ($item in $files) {
        $keys = @($item.PSObject.Properties.Name)
        if (@($keys | Where-Object { $_ -notin @('path','table','contract','rows','sha256','columns') }).Count -gt 0) { throw 'Manifest contains unsupported fields.' }
        if ([string]::IsNullOrWhiteSpace([string]$item.path) -or [string]::IsNullOrWhiteSpace([string]$item.table)) { throw 'Each file needs a relative path and src target.' }
        if ([string]$item.table -notmatch '^src\.([A-Za-z][A-Za-z0-9_]*)$') { throw "Import target must be a table in src: $($item.table)" }
        $item | Add-Member -NotePropertyName resolvedTable -NotePropertyValue $Matches[1] -Force
        $csvPath = [IO.Path]::GetFullPath((Join-Path $base ([string]$item.path)))
        $prefix = $base.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
        if (-not $csvPath.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) { throw 'CSV paths must remain inside the manifest folder.' }
        if (-not (Test-Path -LiteralPath $csvPath -PathType Leaf)) { throw "CSV not found: $($item.path)" }
        $item | Add-Member -NotePropertyName resolvedPath -NotePropertyValue $csvPath -Force
        if ([int]$item.rows -lt 0 -or [string]$item.sha256 -notmatch '^[0-9a-fA-F]{64}$') { throw "Invalid row count or SHA256 in manifest: $($item.path)" }
        $columns = @($item.columns | ForEach-Object { [string]$_ })
        if ($columns.Count -eq 0 -or $columns.Count -ne (@($columns | Select-Object -Unique)).Count) { throw "Invalid columns in manifest: $($item.path)" }
        $reader = [IO.StreamReader]::new($csvPath, [Text.Encoding]::UTF8)
        try { $header = $reader.ReadLine() } finally { $reader.Dispose() }
        if ($null -eq $header -or $header.TrimStart([char]0xFEFF) -cne ($columns -join ',')) { throw "CSV header does not match manifest columns: $($item.path)" }
        $actualHash = (Get-FileHash -LiteralPath $csvPath -Algorithm SHA256).Hash
        if ($actualHash -ine [string]$item.sha256) { throw "SHA256 mismatch for $($item.path)." }
    }
    return [pscustomobject]@{ Manifest=$manifest; Base=$base; Files=$files }
}

function Import-Pack([string]$ManifestCandidate, [switch]$RequireP0) {
    $pack = Read-PackManifest $ManifestCandidate
    if ($RequireP0) {
        if ([string]$pack.Manifest.pack -cne 'P0') { throw 'import-p0 requires a manifest with pack=P0.' }
        $required = @('src.SalesRaw','src.InventoryRaw','src.ReturnsRaw')
        $actualTargets = (@($pack.Files | ForEach-Object { [string]$_.table } | Sort-Object) -join '|')
        $requiredTargets = (@($required | Sort-Object) -join '|')
        if ($actualTargets -cne $requiredTargets) { throw 'P0 must contain the three source feeds: sales, inventory and returns.' }
        $rawCount = [int](Invoke-Scalar $DatabaseName 'SELECT (SELECT COUNT_BIG(*) FROM src.SalesRaw)+(SELECT COUNT_BIG(*) FROM src.InventoryRaw)+(SELECT COUNT_BIG(*) FROM src.ReturnsRaw);')
        if ($rawCount -ne 0) { throw 'P0 import requires empty src tables. Restore checkpoint v0 first if you need a clean start.' }
    }
    $connection = New-SqlConnection $DatabaseName
    $transaction = $null
    $completed = [Collections.Generic.List[string]]::new()
    try {
        $connection.Open()
        $transaction = $connection.BeginTransaction()
        foreach ($item in $pack.Files) {
            $schema = Get-SourceColumnMetadata 'src' ([string]$item.resolvedTable)
            foreach ($column in $item.columns) {
                $metadata = @($schema.Rows | Where-Object { [string]$_.name -ceq [string]$column })
                if ($metadata.Count -ne 1 -or [bool]$metadata[0].is_identity -or [bool]$metadata[0].is_computed) { throw "Column is absent, identity or computed in src.$($item.resolvedTable): $column" }
            }
            $tableName = [string]$item.resolvedTable
            $data = [System.Data.DataTable]::new()
            foreach ($column in $item.columns) { [void]$data.Columns.Add([string]$column, [string]) }
            $bulk = [System.Data.SqlClient.SqlBulkCopy]::new($connection, [System.Data.SqlClient.SqlBulkCopyOptions]::Default, $transaction)
            $bulk.DestinationTableName = "[src].[$tableName]"
            $bulk.BatchSize = 5000
            $bulk.BulkCopyTimeout = 1200
            foreach ($column in $item.columns) { [void]$bulk.ColumnMappings.Add([string]$column, [string]$column) }
            $parser = $null
            $rowCount = 0
            try {
                $parser = [Microsoft.VisualBasic.FileIO.TextFieldParser]::new([string]$item.resolvedPath, [Text.Encoding]::UTF8, $true)
                $parser.TextFieldType = [Microsoft.VisualBasic.FileIO.FieldType]::Delimited
                $parser.SetDelimiters(',')
                $parser.HasFieldsEnclosedInQuotes = $true
                $parser.TrimWhiteSpace = $false
                $headerFields = $parser.ReadFields()
                if (($headerFields -join ',') -cne (@($item.columns) -join ',')) { throw "CSV header mismatch: $($item.path)" }
                while (-not $parser.EndOfData) {
                    $fields = $parser.ReadFields()
                    if ($fields.Count -ne $item.columns.Count) { throw "CSV column count mismatch at data row $($rowCount+1): $($item.path)" }
                    $row = $data.NewRow()
                    for ($i=0; $i -lt $fields.Count; $i++) {
                        $row[$i] = if ([string]::IsNullOrEmpty([string]$fields[$i])) { [DBNull]::Value } else { [string]$fields[$i] }
                    }
                    [void]$data.Rows.Add($row)
                    $rowCount++
                    if ($data.Rows.Count -ge $bulk.BatchSize) { $bulk.WriteToServer($data); $data.Clear() }
                }
                if ($data.Rows.Count -gt 0) { $bulk.WriteToServer($data) }
                if ($rowCount -ne [int]$item.rows) { throw "Row count mismatch for $($item.path): manifest=$($item.rows), parsed=$rowCount" }
                $completed.Add("$($item.path) -> src.$tableName ($rowCount rows)")
            } finally {
                if ($parser) { $parser.Dispose() }
                $bulk.Dispose()
                $data.Dispose()
            }
        }
        $transaction.Commit()
        foreach ($line in $completed) { Write-Host "Imported $line" }
        Write-Host 'Import committed to src. No ETL procedure was executed.'
    } catch {
        if ($transaction) { try { $transaction.Rollback() } catch { } }
        throw
    } finally {
        if ($transaction) { $transaction.Dispose() }
        $connection.Dispose()
    }
}

function Run-ETL([string]$SelectedFeed) {
    $procedures = switch ($SelectedFeed) {
        'sales' { @('etl.LoadSales') }
        'inventory' { @('etl.LoadInventory') }
        'returns' { @('etl.LoadReturns') }
        default { @('etl.LoadSales','etl.LoadInventory','etl.LoadReturns') }
    }
    foreach ($procedure in $procedures) {
        $parts = $procedure.Split('.')
        Invoke-NonQuery $DatabaseName "EXEC [$($parts[0])].[$($parts[1])];" 1200
        $status = [string](Invoke-Scalar $DatabaseName "SELECT TOP (1) Status FROM dbo.LoadLog WHERE PackageName=N'$procedure' ORDER BY LoadId DESC;")
        if ($status -cne 'SUCCEEDED') { throw "$procedure did not finish with SUCCEEDED (LoadLog status=$status). Inspect dbo.LoadLog before retrying." }
        Write-Host "$procedure SUCCEEDED."
    }
    if ($SelectedFeed -ceq 'all' -and (Test-P0SourceCounts)) {
        if (-not (Test-BackupExists 'p0')) { [void](Save-Backup -BackupName 'p0') }
        else { Write-Host "Checkpoint 'p0' already exists and was left unchanged." }
    }
}

function Test-P0SourceCounts {
    if (-not (Test-Path -LiteralPath $P0ManifestPath)) { return $false }
    $pack = Read-PackManifest 'data/P0/manifest.json'
    if ([string]$pack.Manifest.pack -cne 'P0') { return $false }
    foreach ($item in $pack.Files) {
        $tableName = [string]$item.resolvedTable
        $count = [int](Invoke-Scalar $DatabaseName "SELECT COUNT_BIG(*) FROM [src].[$tableName];")
        if ($count -ne [int]$item.rows) { return $false }
    }
    return $true
}

function Show-Verification {
    $summary = Invoke-DataTable $DatabaseName @"
SELECT N'src.SalesRaw' AS ObjectName, COUNT_BIG(*) AS Rows FROM src.SalesRaw
UNION ALL SELECT N'src.InventoryRaw', COUNT_BIG(*) FROM src.InventoryRaw
UNION ALL SELECT N'src.ReturnsRaw', COUNT_BIG(*) FROM src.ReturnsRaw
UNION ALL SELECT N'stg.Sales', COUNT_BIG(*) FROM stg.Sales
UNION ALL SELECT N'stg.Inventory', COUNT_BIG(*) FROM stg.Inventory
UNION ALL SELECT N'stg.Returns', COUNT_BIG(*) FROM stg.Returns
UNION ALL SELECT N'dbo.FactSales', COUNT_BIG(*) FROM dbo.FactSales
UNION ALL SELECT N'dbo.FactInventoryDaily', COUNT_BIG(*) FROM dbo.FactInventoryDaily
UNION ALL SELECT N'dbo.FactReturns', COUNT_BIG(*) FROM dbo.FactReturns;
"@
    $objects = Invoke-DataTable $DatabaseName @"
SELECT
  (SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped=0) AS Tables,
  (SELECT COUNT(*) FROM sys.procedures p JOIN sys.schemas s ON p.schema_id=s.schema_id WHERE s.name=N'etl') AS EtlProcedures,
  (SELECT COUNT(*) FROM sys.views v JOIN sys.schemas s ON v.schema_id=s.schema_id WHERE s.name=N'reporting') AS ReportingViews,
  (SELECT COUNT(*) FROM dbo.DimDate) AS DimDateRows,
  (SELECT COUNT(*) FROM dbo.DimProduct) AS DimProductRows,
  (SELECT COUNT(*) FROM dbo.DimStore) AS DimStoreRows;
"@
    Write-Host 'Object and dimension summary:'
    $objects | Format-Table -AutoSize | Out-String | Write-Host
    Write-Host 'Raw, staging and fact counts:'
    $summary | Format-Table -AutoSize | Out-String | Write-Host
    $loads = Invoke-DataTable $DatabaseName 'SELECT TOP (10) LoadId, PackageName, Status, RowsRead, RowsLoaded, RowsRejected, StartedAt, FinishedAt FROM dbo.LoadLog ORDER BY LoadId DESC;'
    Write-Host 'Latest ETL runs:'
    if ($loads.Rows.Count -gt 0) { $loads | Format-Table -AutoSize | Out-String | Write-Host } else { Write-Host 'No ETL runs yet.' }
}

function Build-Project {
    if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) { throw '.NET SDK is not installed; setup/import/ETL do not require it.' }
    $ErrorActionPreference = 'Continue'
    try { & dotnet build (Join-Path $ProjectPath 'RetailDW.sqlproj') --nologo 2>&1 | ForEach-Object { Write-Host "$_" } }
    finally { $ErrorActionPreference = 'Stop' }
    if ($LASTEXITCODE -ne 0) { throw 'RetailDW.sqlproj build failed.' }
}

try {
    switch ($Action) {
        'help' { Show-Help }
        'setup' { Start-LocalSqlServer; Install-V0 }
        'import-p0' { Start-LocalSqlServer; Import-Pack 'data/P0/manifest.json' -RequireP0 }
        'import-pack' {
            if ([string]::IsNullOrWhiteSpace($PackPath)) { throw 'Use -PackPath with a participant-safe manifest.' }
            Start-LocalSqlServer
            Import-Pack $PackPath
        }
        'etl' { Start-LocalSqlServer; Run-ETL $Feed }
        'verify' { Start-LocalSqlServer; Show-Verification }
        'backup' {
            if (-not $Force) { throw 'Backup requires explicit -Force, for example backup -Name p0 -Force.' }
            Start-LocalSqlServer
            [void](Save-Backup -BackupName $Name -Overwrite)
        }
        'restore' {
            if (-not $Force) { throw 'Restore replaces RetailDW_Workshop and requires explicit -Force.' }
            Start-LocalSqlServer
            Restore-Backup $Name
        }
        'apply-sql' {
            if ([string]::IsNullOrWhiteSpace($Path)) { throw 'Use -Path with one SQL file inside this repository.' }
            Start-LocalSqlServer
            Invoke-SqlFile $Path
        }
        'build' { Build-Project }
    }
} catch {
    Write-Error $_.Exception.Message
    exit 1
}

