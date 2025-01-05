fx_version 'cerulean'
game 'gta5'
lua54 'yes' 

author 'Creed'
description 'Metal Detector Purchase Script'
version '1.0.0'

files {
    'stream/w_am_metaldetector.ydr',
    'stream/w_am_metaldetector.ytd',
    'stream/gen_w_am_metaldetector.ytyp',
    'stream/w_am_digiscanner.ydr',
    'stream/w_am_digiscanner.ytd',
    'stream/w_am_digiscanner+hi.ytd'
}

data_file 'DLC_ITYP_REQUEST' 'stream/gen_w_am_metaldetector.ytyp'

shared_scripts {'config.lua', '@ox_lib/init.lua'}
client_script 'client.lua'
server_script 'server.lua'



