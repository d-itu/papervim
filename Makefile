export NVIM_APPNAME=papervim

LUA_SOURCES := $(shell find src -type f -name "*.lua")
LUA_TARGETS := $(patsubst src/%.lua,build/%.lua,$(LUA_SOURCES))

.PHONY: all
all: build sync

.PHONY: build
build: compile clean_orphans resources .luarc.json

.PHONY: clean_orphans
clean_orphans:
	rm -f $(filter-out $(LUA_TARGETS),$(shell find build -type f -name "*.lua"))

.luarc.json: build.lua
	nvim -l build.lua generate_luarc

.PHONY: compile
compile: build/init.lua $(LUA_TARGETS)

build/%.lua: src/%.lua
	@mkdir -p $(@D)
	luajit -b $< $@

.PHONY: clean
clean:
	rm -rf build

.PHONY: update
update:
	nvim -l build.lua update

.PHONY: sync
sync:
	nvim -l build.lua sync

.PHONY: clean_plugins
clean_plugins:
	nvim -l build.lua clean

.PHONY: resources
resources:
	rsync -av --delete \
	--exclude='*.lua' \
	--exclude='nvim-pack-lock.json' \
	src/ build

.PHONY: debug
debug:
	rsync -av --delete \
	--exclude='nvim-pack-lock.json' \
	src/ build

.PHONY: run
run:
	nvim -l build.lua $(CMD)
