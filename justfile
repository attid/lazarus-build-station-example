set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

image_latest := "ghcr.io/attid/lazarus-build-station:latest"
image_amd64 := "ghcr.io/attid/lazarus-build-station:latest-amd64"
image_386 := "ghcr.io/attid/lazarus-build-station:latest-i386"
container_workspace := "/workspace"

default:
  @just --list

pull:
  docker pull {{image_latest}}
  docker pull {{image_amd64}}
  docker pull {{image_386}}

_build image target_os target_cpu:
  docker run --rm \
    -v "$PWD:{{container_workspace}}" \
    --user "$(id -u):$(id -g)" \
    -e TARGET_OS={{target_os}} \
    -e TARGET_CPU={{target_cpu}} \
    {{image}} \
    bash {{container_workspace}}/scripts/build-in-container.sh

make:
  just make-linux64
  just make-win64
  just make-linux32
  just make-win32

make-linux64:
  just _build {{image_amd64}} linux x86_64

make-win64:
  just _build {{image_amd64}} win64 x86_64

make-linux32:
  just _build {{image_386}} linux i386

make-win32:
  just _build {{image_386}} win32 i386

test:
  fpc -Fuapp tests/demo_logic_test.pas
  ./tests/demo_logic_test

clean:
  rm -rf app/lib
  rm -rf dist
  rm -f app/*.o app/*.ppu app/*.res app/lazarus_build_station_example
  rm -f app/*.exe
  rm -f tests/*.o tests/*.ppu tests/demo_logic_test
  rm -f packagefiles.xml

status:
  git status -sb
