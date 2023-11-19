test:
	nvim --headless -u tests/init.lua -c "PlenaryBustedDirectory tests { init = 'tests/init.lua' }"
