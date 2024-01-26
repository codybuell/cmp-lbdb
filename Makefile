lint:
	docker run --rm -v "$$(pwd):/data" ghcr.io/lunarmodules/luacheck:latest .
