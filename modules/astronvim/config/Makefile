all: lua/plugins/demo.lua

lua/plugins/%.lua: fnl/%.fnl
	fennel --compile $< > $@
