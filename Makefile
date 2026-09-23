.PHONY: build run test fmt clean

build:
	zig build

run:
	zig build run

test:
	zig build test

fmt:
	zig fmt build.zig src

clean:
	powershell -NoProfile -Command "Remove-Item -Recurse -Force -ErrorAction SilentlyContinue .zig-cache, zig-out"
