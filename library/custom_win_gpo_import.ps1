#!powershell
#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options = @{
        domain      = @{type="str"; required=$true}
        backup_path = @{type="str"; required=$true}
        gpo_nam     = @{type="str"; required=$false; default=$null}
    }
}

$module = [Ansible.Basic.AnsibleModule]::Create($args; $spec)

#required in playbook
$backupPath = $module.Params.backup_path
$gpoName    = $module.Params.gpo_name
#optional in playbook
$domain     = $module.Params.domain


#logic
#get all available ps module on server
$ModuleInstalled = Get-Module -ListAvailable  

if ($ModuleInstalled.Name -contains "ActiveDirectory") {  

    #if AD module present, import GP module
    Import-Module GroupPolicy
    
    #check if GPO exist with specified name
    $existingGPO = Get-GPO -Name $gpoName -Domain $domain -ErrorAction SilentlyContinue

    if ($existingGPO) {
        $module.Result.changed = $false
        $module.Result.gpo_id  = $existingGPO.Id.ToString()
        $module.Result.msg     = "GPO '$gpoName' already exists"
        $module.ExitJson()
    }

    $importedGPO = Import-GPO -BackupGpoName $gpoName -Path $backupPath -TargetName $gpoName -CreateIfNeeded -Domain $domain

    $module.Result.changed = $true
    $module.Result.gpo_id  = $importedGPO.Id.ToString()
    $module.Result.msg     = "GPO '$gpoName' imported with succes"
    $module.ExitJson()

} else {
    
    $module.Result.changed = $false
    $module.Result.msg     = "ActiveDirectory module not installed on this host"
    $module.ExitJson()
}