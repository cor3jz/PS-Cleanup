$GitHubRepoOwner = "cor3jz"
$GitHubRepoName = "PS-Cleanup"
$LocalVersionFile = "version.json"
$TempZipFile = Join-Path $env:TEMP "github_update_$(Get-Date -Format 'ddMMyyyyHHmmss').zip"

$Host.UI.RawUI.WindowTitle = "Обновление Cleanup Utility"

$logFile = Join-Path $PSScriptRoot 'update-debug.log'
if (Test-Path -Path $logFile -PathType Leaf) {
    Remove-Item -Path $logFile -Force
}

function Write-Log {
    param (
        [string]$message,
        [ValidateSet("INFO", "WARNING", "ERROR", "DEBUG")]
        [string]$level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$level] $message"
    Add-Content -Path $logFile -Value $logEntry -Encoding UTF8
    Write-Host $message
}

function Get-LocalVersion {
    if (Test-Path $LocalVersionFile) {
        try {
            $versionData = Get-Content $LocalVersionFile -Raw | ConvertFrom-Json -ErrorAction Stop
            return $versionData.version
        } catch {
            Write-Log -level "ERROR" -message "Ошибка чтения version.json: $_"
            return "0.0.0"
        }
    }
    return "0.0.0"
}

function Get-RemoteVersion {
    try {
        $apiUrl = "https://api.github.com/repos/$GitHubRepoOwner/$GitHubRepoName/releases/latest"
        $headers = @{
            "Accept" = "application/vnd.github.v3+json"
        }
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers
        return $response.tag_name.Trim('v')
    } catch {
        Write-Log -level "ERROR" -message "Ошибка при проверке обновлений: $_"
        return $null
    }
}

function Install-Update {
    param (
        [string]$zipUrl
    )
    
    try {
        Write-Log -level "DEBUG" -message "Загрузка обновления..."
        $progressPreference = 'silentlyContinue'
        Invoke-WebRequest -Uri $zipUrl -OutFile $TempZipFile
        
        Write-Log -level "DEBUG" -message "Распаковка обновления..."
        Expand-Archive -Path $TempZipFile -DestinationPath . -Force
        
        Write-Log -level "DEBUG" -message "Очистка временных файлов..."
        Remove-Item $TempZipFile -Force -ErrorAction SilentlyContinue
        
        return $true
    } catch {
        Write-Log -level "ERROR" -message "Ошибка при установке: $_"
        if (Test-Path $TempZipFile) {
            Remove-Item $TempZipFile -Force -ErrorAction SilentlyContinue
            Write-Log -level "DEBUG" -message "Временные файлы удалены"
        }
        return $false
    }
}

Write-Log -level "INFO" -message "Проверка обновлений для $GitHubRepoOwner/$GitHubRepoName"

$localVer = [System.Version](Get-LocalVersion)
Write-Log -level "INFO" -message "Текущая версия: $localVer"

$remoteVerStr = Get-RemoteVersion
if (-not $remoteVerStr) {
    Write-Log -level "ERROR" -message "Не удалось проверить обновления"
    exit 1
}

try {
    $remoteVer = [System.Version]$remoteVerStr
} catch {
    Write-Log -level "ERROR" -message "Некорректный формат версии в релизе: $remoteVerStr"
    exit 1
}

Write-Log -level "INFO" -message "Доступная версия: $remoteVer"

if ($remoteVer -gt $localVer) {
    Write-Log -level "INFO" -message "Найдено обновление! Начинаю установку..."
    
    try {
        $apiUrl = "https://api.github.com/repos/$GitHubRepoOwner/$GitHubRepoName/releases/latest"
        $releaseInfo = Invoke-RestMethod -Uri $apiUrl -Method Get
        $zipUrl = $releaseInfo.zipball_url
        
        if (-not $zipUrl) {
            throw "Не найдена ссылка для скачивания"
        }
        
        $success = Install-Update -zipUrl $zipUrl
        
        if ($success) {
            Write-Log -level "DEBUG" -message "Обновление успешно установлено"
            exit 0
        } else {
            throw "Ошибка при установке"
        }
    } catch {
        Write-Log -level "ERROR" -message "Ошибка процесса обновления: $_"
        exit 1
    }
} else {
    Write-Log -level "INFO" -message "Установлена актуальная версия. Обновление не требуется."
    exit 0
}