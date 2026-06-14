# Import Group Policy Object
Custom Ansible module written in PowerShell that imports a Group Policy Object  (GPO) backup into Active Directory



## Usage

`ansible-playbook playbook_import_gpo.yml --ask-vault-pass`

#### Usage example:

```yml
# Import GPO to AD (All parametars required)
- name: Import GPO
    custom_win_gpo_import:
      backup_path: "c:\\adm\\GPO-bkp"
      gpo_name: "Custom GPO"
      domain: "lab.local"
``` 
```ini
#Set vault for windows_user and windows_user_password.
ansible_user={{ windows_user }}
ansible_password={{ windows_user_password }}
```
#### Note:
>If GPO with same name already exist, will not overwrite the GPO

>Active Directory PowerShell Module must be present on server

> Make sure backup GPO exist in specified folder, and path and domain are set.

