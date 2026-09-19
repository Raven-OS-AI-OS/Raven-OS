.PHONY: build clean check test verify-iso

build:
	./scripts/build.sh

clean:
	./scripts/clean-build.sh

check:
	./scripts/check-compatibility.sh
	./scripts/check-layout.sh

test: check
	./tests/run.sh

verify-iso:
	./scripts/verify-iso.sh
