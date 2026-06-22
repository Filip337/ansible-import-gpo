#!powershell
#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options = @{
        backup_path = @{type="str"; required=$true}
        gpo_name    = @{type="str"; required=$true}
        domain      = @{type="str"; required=$true}
        force       = @{type="bool"; required=$false; default=$false}
    }
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

#required in playbook
$backupPath = $module.Params.backup_path
$gpoName    = $module.Params.gpo_name
$domain     = $module.Params.domain
$force      = $module.Params.force

#module logic
#get all available ps module on server
try {
$PsModuleInstalled = Get-Module -ListAvailable  

if ($PsModuleInstalled.Name -contains "ActiveDirectory") {  

    #if AD module present, import GP module
    Import-Module GroupPolicy
    
    #check if GPO exist, if exist do not import
    $existingGPO = Get-GPO -Name $gpoName -Domain $domain -ErrorAction SilentlyContinue
    if ($existingGPO -and $force -like "false") {
        $module.Result.changed = $false
        $module.Result.gpo_id  = $existingGPO.Id.ToString()
        $module.Result.msg     = "GPO '$gpoName' already exists. Set force to true in playbook to import it anyway"
        $module.ExitJson()
    } if ($existingGPO -and $force -like "true") {
          $module.Result.changed = $true
          $module.Result.gpo_id  = $existingGPO.Id.ToString()
          $module.Result.msg     = "GPO '$gpoName' overwriten. Force is set to true in playbook"
          $module.ExitJson()
    } else {
    #if does not exist, import GPO, get GPO ID and message
    $importedGPO = Import-GPO -BackupGpoName $gpoName -Path $backupPath -TargetName $gpoName -CreateIfNeeded -Domain $domain
    $module.Result.changed = $true
    $module.Result.gpo_id  = $importedGPO.Id.ToString()
    $module.Result.msg     = "GPO '$gpoName' imported with succes"
    $module.ExitJson()
    }
} else {
    #AD moddule not present on mashine
    $module.Result.changed = $false
    $module.Result.msg     = "AD module not installed"
    $module.ExitJson()
}
} catch {
    $module.FailJson("Fatal error while executing module: $($_.Exception.Message)")
}