resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

description 'ESX Discord Perms'

version '1.0.0'

server_scripts {
	"config.lua",
	"server.lua"
}

server_export "IsRolePresent"
server_export "GetRoles"
