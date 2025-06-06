fx_version 'adamant'
games {"common"}
lua54 'yes'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'


description "BLACKOUT"

author "phil"

version '1.0.0'


shared_scripts {
	'@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {    
    'server/server.lua'
}

dependencies {
    'rsg-core',
    'ox_lib',
}

lua54 'yes'