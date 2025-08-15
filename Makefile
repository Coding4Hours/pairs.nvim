.SUFFIXES:

all: documentation lint 

documentation:
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua require('mini.doc').generate()" -c "qa!"

documentation-ci: deps documentation

lint:
	stylua . -g '*.lua' -g '!deps/' -g '!nightly/'
	luacheck plugin/ lua/
