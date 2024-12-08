fx_version 'cerulean'
game 'gta5'

client_script 'client.lua'
server_script 'server.lua'

-- Certifique-se de que oxmysql está listado como dependência
dependencies {
    'oxmysql'
}

lua54 'yes'
