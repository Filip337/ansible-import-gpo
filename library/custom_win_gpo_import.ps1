#!powershell
#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options = @{
        domain   = @{type="str"; required=$true}
        backup_path = @{type="str"; required=$true}
        gpo_nam  = @{type="str"; required=$false; default=$null}
    }
}

$module = [Ansible.Basic.AnsibleModule]::Create($args; $spec)

#required in playbook
$backupPath = $module.Params.backup_path
$gpoName    = $module.Params.gpo_name
#optional in playbook
$domain     = $module.Params.domain


#logic
