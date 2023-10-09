
# функция для добавления линии разделения, чтобы был более читаемый вывод
function Write-Separator {
    Write-Host "------------------------------------------------------"
}

# выводится информация об интерфейсах и спрашивается у пользователя
# какой интерфейс он хочет поменять
netsh interface ip show config | find "Configuration for interface"
$interfaceName = Read-Host "Which interface do you want to change?" 

Write-Separator

$automatic = Read-Host "Do you want to configure settings of '$interfaceName' automatically? (y/n)" 

# если автоматически - то настраивается через dhcp
if ($automatic -eq "y") {
    Write-Host "Configuring IPv4, Subnet Mask, Default Gateway and DNS through DHCP..."
    netsh interface ipv4 set address $interfaceName dhcp
    netsh interface ipv4 set dns $interfaceName dhcp

# если не автоматически - то настраивается вручную
} elseif ($automatic -eq "n") {
    $myipv4 = Read-Host "Enter IPV4"
    $mask = Read-Host "Enter Mask"
    $gateway = Read-Host "Enter Gateway"
    $mydns = Read-Host "Enter DNS"
    
    Write-Separator
    Write-Host "Setting provided values..."

    netsh interface ip set address name=$interfaceName static address=$myipv4 mask=$mask gateway=$gateway 
    netsh interface ip set dns name=$interfaceName static $mydns validate=no

# если неправильный ввод - программа завершается
} else {
    Write-Host "Unknown value: $automatic"
    Exit
}

# информация о сетевом интерфейсе после изменения
Write-Separator
Write-Host "Information about host after configuring:"

netsh interface ip show config | find "$interfaceName"

# получение объекта сетевого адаптера 
$adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.Name -eq $interfaceName }

# получение сетевого адаптера Windows
$WmiAdapter = Get-WmiObject Win32_NetworkAdapter | Where-Object { $_.Name -eq $interfaceName }
if ($adapter -eq $null) {
    Write-Host "Network interface '$interfaceName' not found."
    return
}

# информация о сетевой карте, ее модели и наличии линка
Write-Host "Network card: $($adapter.Name)"
Write-Host "Network card model: $($adapter.InterfaceDescription)"
Write-Host "Physical connection available: $($adapter.LinkSpeed -ne 0)"

# информация о скорости и duplex для сетевого интерфейса
if ($adapter.LinkSpeed -ne 0) {
    Write-Host "Adapter speed: $($adapter.LinkSpeed)"
    if ($WmiAdapter) {
        $DuplexMode = $WmiAdapter.Duplex
        Write-Host "Duplex Mode: $($DuplexMode)"
    } else {
        Write-Host "Duplex Mode not found for '$interfaceName'"
    }
}
