export NVIM_APPNAME=papervim

build: compile build_script

LUA_SOURCES := $(shell find src/lua -type f -name "*.lua")
LUA_TARGETS := $(patsubst src/%.lua,build/%.lua,$(LUA_SOURCES))

compile: build/init.lua $(LUA_TARGETS)

build_script: build/build_stamp

build/build_stamp: build.lua
	@touch $@
	nvim -l build.lua

build/%.lua: src/%.lua
	@mkdir -p $(@D)
	luajit -b $< $@

clean:
	rm -rf build

.PHONY: compile clean build_script build

