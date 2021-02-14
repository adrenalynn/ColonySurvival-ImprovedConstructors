# variables
modname = ImprovedConstructors
zipname = $(modname)-$(version).zip
dllname = $(modname).dll
version = $(shell cat modInfo.json | awk '/"version"/ {print $$3}' | head -1 | sed 's/[",]//g')
zip_files_extra = *.json textures
build_dir = $(modname)
gamedir = /local/games/Steam/steamapps/common/Colony\ Survival
linkdir = $(gamedir)/colonyserver_Data/Managed

$(dllname): *.cs */*.cs
	mcs /target:library -nostdlib -r:$(linkdir)/Assembly-CSharp.dll,$(linkdir)/UnityEngine.CoreModule.dll,$(linkdir)/mscorlib.dll,$(linkdir)/System.dll,$(linkdir)/System.Core.dll,$(linkdir)/Steamworks.NET.dll,$(linkdir)/System.IO.Compression.dll,$(linkdir)/System.IO.Compression.FileSystem.dll,$(linkdir)/Newtonsoft.Json.dll,$(linkdir)/UnityEngine.TextRenderingModule.dll -out:"$(dllname)" -sdk:4 *.cs */*.cs

$(zipname): $(dllname) $(zip_files_extra)
	$(RM) $(zipname)
	mkdir -p $(build_dir)
	cp -r $(dllname) $(zip_files_extra) $(build_dir)/
	zip -r $(zipname) $(build_dir)
	$(RM) -r $(build_dir)

.PHONY: build default clean all zip install serverlog clientlog
build: $(dllname)

default: build

clean:
	$(RM) $(dllname) $(zipname)

all: clean default zip

zip: $(zipname)

install: build checkjson zip
	$(RM) -r $(gamedir)/gamedata/mods/$(build_dir)
	unzip $(zipname) -d $(gamedir)/gamedata/mods

checkjson: *.json
	find . -type f -name "*.json" | while read f; do echo $$f; json_pp <$$f >/dev/null; done

serverlog:
	less $(gamedir)/gamedata/logs/server/$$(ls -1rt $(gamedir)/gamedata/logs/server | tail -1)

clientlog:
	less $(gamedir)/gamedata/logs/client/$$(ls -1rt $(gamedir)/gamedata/logs/client | tail -1)

