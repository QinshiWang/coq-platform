#!/usr/bin/env bash

###################### COPYRIGHT/COPYLEFT ######################

# (C) 2020..2021 Michael Soegtrop

# Released to the public under the
# Creative Commons CC0 1.0 Universal License
# See https://creativecommons.org/publicdomain/zero/1.0/legalcode.txt

###################### CREATE SMOKE TEST KIT ######################

# This script extracts from each installed coq opam package one or more test
# files and creates a shell and DOS script to coqc all these files.

###################### Script safety and debugging settings ######################

case $BASH_VERSION in
  1*|2*|3*)
    echo "Bash version 4 or greater required"
    exit 1
  ;;
esac

set -o nounset
set -o errexit

###### The scripts supports a regexp package name pattern as $1 #####

pattern="${1:-^coq-}"

###### Clear and create smoke test folder #####

rm -rf smoke-test-kit
mkdir smoke-test-kit

###### Get package list name #####

source "$(dirname "$0")/get_names_from_switch.sh"

###### Get filtered list of explicitly installed packages #####

echo "Create package list"

packages="$(opam list --installed-roots --short --columns=name | grep "${pattern}" | cat)"

##### Associate package name with test/example file(s) #####

# A space sparated list of file paths in the package source tree [requires]
declare -A TEST_FILES
# coqc options required to run the test, typically -Q or -R options [optional]
declare -A COQ_OPTION
# A AWK command for patching test files (typically require statements) [optional]
declare -A PATCH_CMDS

TEST_FILES[coq-aac-tactics]='theories/Tutorial.v'
TEST_FILES[coq-bignums]='tests/success/bigQ.v tests/success/NumberScopes.v'
TEST_FILES[coq-compcert-32]='lib/Coqlib.v'
COQ_OPTION[coq-compcert-32]='-Q $COQLIB/../coq-variant/compcert32/compcert compcert'
TEST_FILES[coq-compcert]='lib/Coqlib.v'
TEST_FILES[coq-coqeal]='refinements/examples/irred.v'
TEST_FILES[coq-coqprime-generator]=''
TEST_FILES[coq-coqprime]='src/Coqprime/examples/russell1.v'
PATCH_CMDS[coq-coqprime]='/^Require Import PocklingtonRefl.$/ {print "From Coqprime "$0; next}'
TEST_FILES[coq-coquelicot]='examples/BacS2013.v'
PATCH_CMDS[coq-coquelicot]='/^Require Import .*Rcomplements.*.$/ {print "From Coquelicot "$0; next}'
TEST_FILES[coq-coqutil]='src/coqutil/Map/SortedList.v'
TEST_FILES[coq-corn]=''
TEST_FILES[coq-deriving]='tests/tree.v'
TEST_FILES[coq-dpdgraph]='tests/Test.v'
TEST_FILES[coq-elpi]='examples/tutorial_coq_elpi_command.v examples/tutorial_elpi_lang.v'
TEST_FILES[coq-elpi~8.12]='theories/examples/example_reflexive_tactic.v'
TEST_FILES[coq-elpi~8.13~2021.02]='examples/tutorial_coq_elpi.v examples/tutorial_elpi_lang.v'
TEST_FILES[coq-elpi~dev]='examples/tutorial_coq_elpi.v examples/tutorial_elpi_lang.v'
TEST_FILES[coq-equations]='examples/Fin.v examples/STLC.v'
TEST_FILES[coq-ext-lib]='examples/MonadReasoning.v examples/Printing.v'
TEST_FILES[coq-extructures]='../../test_files/coq-extructures/just_require.v'
TEST_FILES[coq-flocq]='examples/Average.v' # In fixing: examples/Cody_Waite.v
TEST_FILES[coq-flocq3]='examples/Average.v' # In fixing: examples/Cody_Waite.v
PATCH_CMDS[coq-flocq3]='{gsub(/^From Flocq Require/, "From Flocq3 Require", $0); print $0; next}'
TEST_FILES[coq-gappa]='testsuite/example-20101018.v testsuite/example-20090706.v testsuite/example-20080417.v'
# Note: the latest version of coq-gappa does not require patches, but versions in older picks do require it
PATCH_CMDS[coq-gappa]='/^Require Import Gappa_tactic.$/ {print "From Gappa "$0; next}'
TEST_FILES[coq-gappa-flocq3]='testsuite/example-20101018.v testsuite/example-20090706.v testsuite/example-20080417.v'
PATCH_CMDS[coq-gappa-flocq3]='/^From Gappa Require/ {sub("From Gappa Require", "From GappaFlocq3 Require", $0); print $0; next} /^From Flocq Require/ {sub("From Flocq Require", "From Flocq3 Require", $0); print $0; next}'
TEST_FILES[coq-hammer-tactics]='/examples/tutorial/sauto/isort.v'
TEST_FILES[coq-hammer]='../../test_files/coq-hammer/test_eprover.v ../../test_files/coq-hammer/test_z3.v'
TEST_FILES[coq-hierarchy-builder]='examples/demo2/classical.v examples/demo2/stage10.v examples/demo2/stage11.v'
TEST_FILES[coq-hierarchy-builder~8.12]='demo2/classical.v demo2/stage10.v demo2/stage11.v'
PATCH_CMDS[coq-hierarchy-builder~8.12]='/^From HB.demo2 / {sub("From HB.demo2 ", "", $0); print $0; next}'
TEST_FILES[coq-hierarchy-builder~8.13~2021.02]='demo2/classical.v demo2/stage10.v demo2/stage11.v'
PATCH_CMDS[coq-hierarchy-builder~8.13~2021.02]='/^From HB.demo2 / {sub("From HB.demo2 ", "", $0); print $0; next}'
TEST_FILES[coq-hott]='theories/Analysis/Locator.v'
COQ_OPTION[coq-hott]='-noinit -indices-matter'
TEST_FILES[coq-interval]='testsuite/example-20071016.v testsuite/example-20120205.v testsuite/example-20140221.v'
TEST_FILES[coq-interval-flocq3]='testsuite/example-20071016.v testsuite/example-20120205.v testsuite/example-20140221.v'
PATCH_CMDS[coq-interval-flocq3]='/Interval/ {sub("Interval", "IntervalFlocq3", $0); print $0; next}'
TEST_FILES[coq-iris-heap-lang]='tests/heapprop.v'
TEST_FILES[coq-iris]='tests/heapprop.v'
TEST_FILES[coq-itauto]='test-suite/no_test_lia.v' # test-suite/arith.v  has issues with Int63.v
TEST_FILES[coq-libhyps]='Demo/demo.v'
TEST_FILES[coq-math-classes]=''
TEST_FILES[coq-mathcomp-algebra-tactics]='' # 'examples/field_examples.v examples/ring_examples.v' both do not work for 8.16
TEST_FILES[coq-mathcomp-algebra]='mathcomp/algebra/finalg.v'
TEST_FILES[coq-mathcomp-analysis]=''
TEST_FILES[coq-mathcomp-bigenough]='bigenough.v'
TEST_FILES[coq-mathcomp-character]='mathcomp/character/all_character.v'
TEST_FILES[coq-mathcomp-field]='mathcomp/field/finfield.v'
TEST_FILES[coq-mathcomp-fingroup]='mathcomp/fingroup/fingroup.v'
TEST_FILES[coq-mathcomp-finmap]='finmap.v'
TEST_FILES[coq-mathcomp-multinomials]=''
TEST_FILES[coq-mathcomp-real-closed]='theories/complex.v'
TEST_FILES[coq-mathcomp-solvable]='mathcomp/solvable/abelian.v'
TEST_FILES[coq-mathcomp-ssreflect]='mathcomp/ssreflect/ssrbool.v'
TEST_FILES[coq-mathcomp-zify]='examples/divmod.v examples/boolean.v'
TEST_FILES[coq-menhirlib]='coq-menhirlib/src/Alphabet.v'
TEST_FILES[coq-mtac2]='examples/basics_tutorial.v examples/tauto.v'
TEST_FILES[coq-mtac2~8.12]='examples/tactics.v examples/tauto.v'
TEST_FILES[coq-ott]='../../test_files/coq-ott/regexp.v'
TEST_FILES[coq-paramcoq]='test-suite/Parametricity.v'
TEST_FILES[coq-quickchick]='' # QuickChick requires OCaml, which is currently only provided in "from sources" mode - when OCaml is added use 'examples/Tutorial.v'
TEST_FILES[coq-record-update]='/tests/RecordSetTests.v'
TEST_FILES[coq-reduction-effects]='tests/PrintEffect.v'
TEST_FILES[coq-reglang]='theories/dfa.v'
TEST_FILES[coq-relation-algebra~8.14~2022.01]='compiler_opts.v imp.v'
TEST_FILES[coq-relation-algebra~8.14~2022.04]='compiler_opts.v imp.v'
TEST_FILES[coq-relation-algebra~8.15~2022.04]='compiler_opts.v imp.v'
TEST_FILES[coq-relation-algebra]='examples/compiler_opts.v examples/imp.v'
PATCH_CMDS[coq-relation-algebra]='/^Require Import kat .*$/ {print "From RelationAlgebra "$0; next}'
TEST_FILES[coq-serapi]=''
TEST_FILES[coq-simple-io]='test/Example.v test/TestExtraction.v'
TEST_FILES[coq-stdpp]='tests/sets.v'
TEST_FILES[coq-unicoq]='test-suite/microtests.v'
TEST_FILES[coq-unimath]='UniMath/Foundations/Tests.v'
COQ_OPTION[coq-unimath]='-noinit -indices-matter -type-in-type -w -notation-overridden'
TEST_FILES[coq-vst-32]='progs/reverse.v progs/verif_reverse2.v'
COQ_OPTION[coq-vst-32]='-Q $COQLIB/../coq-variant/VST32/VST VST -Q $COQLIB/../coq-variant/compcert32/compcert compcert'
PATCH_CMDS[coq-vst-32]='/^Require Import VST.progs.reverse.$/ {print "Require Import reverse. "; next}'
TEST_FILES[coq-vst]='progs64/reverse.v progs64/verif_reverse2.v'
PATCH_CMDS[coq-vst]='/^Require Import VST.progs64.reverse.$/ {print "Require Import reverse. "; next}'
TEST_FILES[coq-vst~8.12]='progs/reverse.v progs/verif_reverse2.v'
PATCH_CMDS[coq-vst~8.12]='/^Require Import VST.progs.reverse.$/ {print "Require Import reverse. "; next}'

##### Hacks for files #####

# Patch a file using AWK
# $1 = file name to patch
# $2 = awk patch command

function patch_file() {
  if [ -n "$2" ]
  then
    echo "Patching file $1 with $2"
    awk "$2"' {print $0}' $1 > $1.tmp
    mv -f $1.tmp $1
  fi
}

##### Write header of bash runner script #####

smoke_script=smoke-test-kit/run-smoke-test.sh

cat <<-'EOH' > $smoke_script
	#/bin/bash
	# This script runs a small "smoke-test" for all Coq Platform components

	# Exit on all errors
	set -o nounset
	set -o errexit

	# The scripts supports a regexp package name pattern as $1
	pattern="${1:-.*}"

	# Check if coqc is available
	if ! command -v coqc &> /dev/null
	then
	  echo "This script expects that coqc is in the PATH"
	  exit 1
	fi

	# set COQLIB variable
	COQLIB="$(coqc -where | tr -d '\r')"

	# cd to smoke test folder
	HERE="$(pwd)"
	cd "$(dirname $0)"

	# Run one test
	# $1: relative path of file to run
	# $2: coqc options
	function run_test {
	  if [[ "$1" =~ ${pattern} ]]
	  then
	    echo "====================== Running test file $1 ======================"
	      here="$(pwd)"
	      cd "${1%/*}"
	      echo "coqc ${2:-} ${1##*/}"
	      coqc ${2:-} "${1##*/}"
	      cd "$here"
	    echo $'\n\n'
	  fi
	}

	# Run coqc for all smoke test files
	EOH

##### Write header of DOS batch runner script #####

smoke_batch=smoke-test-kit/run-smoke-test.bat

cat <<-'EOH' | sed 's/$/\r/' > $smoke_batch
	@ECHO OFF
	REM This script runs a small "smoke-test" for all Coq Platform components
	
	REM Check if coqc is in the path
	WHERE coqc
	IF ERRORLEVEL 1 (
	    ECHO "This script expects that coqc is in the PATH"
	    EXIT 1
	)
	
	REM set COQLIB variable
	FOR /F "tokens=* USEBACKQ" %%F IN (`coqc -where`) DO SET COQLIB=%%F
	
	REM cd to smoke test folder
	SET HERE=%CD%
	CD "%~dp0%"
	
	GOTO :run_all_tests
	
	REM Run one test
	REM $1: relative path of file to run
	REM $2: coqc options
	
	:run_test
	  ECHO "====================== Running test file %1 ======================"
	  SET HERESUB=%CD%
	  CD "%~dp1"
	  ECHO "coqc %~2 %~nx1"
	  coqc %~2 %~nx1
	  IF ERRORLEVEL 1 (
	    CD "%HERESUB%"
	    ECHO "Compilation with coqc failed"
	    EXIT 1
	  )
	  CD "%HERESUB%"
	  ECHO(
	  ECHO(
	GOTO :EOF
	
	:run_all_tests
	
	REM Run coqc for all smoke test files
	EOH

##### Get the test/example file(s) for each package #####

for package in ${packages}
do
  # First check if a package pick sepcific entry exists
  if [ -n "${TEST_FILES[${package}${COQ_PLATFORM_PACKAGE_PICK_POSTFIX}]+_undef_}" ]
  then
    files="${TEST_FILES[${package}${COQ_PLATFORM_PACKAGE_PICK_POSTFIX}]}"
  # If not check if a generic entry exists
  elif [ -n "${TEST_FILES[${package}]+_undef_}" ]
  then
    files="${TEST_FILES[${package}]}"
  else
    echo "No file list defined for package ${package}"
    exit 1
  fi

  if [ -n "${COQ_OPTION[${package}${COQ_PLATFORM_PACKAGE_PICK_POSTFIX}]+_undef_}" ]
  then
    options='"'"${COQ_OPTION[${package}${COQ_PLATFORM_PACKAGE_PICK_POSTFIX}]}"'"'
  elif [ -n "${COQ_OPTION[${package}]+_undef_}" ]
  then
    options='"'"${COQ_OPTION[${package}]}"'"'
  else
    options=""
  fi

  if [ -n "${PATCH_CMDS[${package}${COQ_PLATFORM_PACKAGE_PICK_POSTFIX}]+_undef_}" ]
  then
    patches="${PATCH_CMDS[${package}${COQ_PLATFORM_PACKAGE_PICK_POSTFIX}]}"
  elif [ -n "${PATCH_CMDS[${package}]+_undef_}" ]
  then
    patches="${PATCH_CMDS[${package}]}"
  else
    patches=""
  fi

  if [ -n "$files" ]
  then
    # get installed version of package (otherwise opam source gives the latest)
    packagefull=$(opam list --installed-roots --short --columns=name,version ${package} | sed 's/ /./')
    echo "Extracting from ${packagefull} the files $files"
    opam source --dir=smoke-test-kit/${package}-src ${packagefull}
    mkdir smoke-test-kit/${package}
    for file in $files
    do
      filename=${file##*/}
      # coqc does not accept file names with -
      filename=${filename/-/_}
      cp "smoke-test-kit/${package}-src/$file" "smoke-test-kit/${package}/${filename}"
      patch_file "smoke-test-kit/${package}/${filename}" "${patches}"
      echo "run_test ${package}/${filename} $options" >> $smoke_script
      echo "CALL :run_test ${package}/${filename} ${options//\$COQLIB/%COQLIB%}"$'\r' >> $smoke_batch
    done
    rm -rf smoke-test-kit/${package}-src
  else
    echo "File list for ${package} is set empty"
  fi
done

##### Write footer of bash runner script #####

echo '' >> $smoke_script
echo 'cd $HERE' >> $smoke_script
echo 'echo "====================== SMOKE TEST SUCCESS ======================"' >> $smoke_script

##### Write footer of DOS batch runner script #####

echo $'\r' >> $smoke_batch
echo 'CD %HERE%'$'\r' >> $smoke_batch
echo 'ECHO "====================== SMOKE TEST SUCCESS ======================"'$'\r' >> $smoke_batch

##### Run bash runner script #####

chmod u+x $smoke_script
echo "On macOS, Linux or unix you can now run " $smoke_script

##### Run batch runner script #####

chmod u+x $smoke_batch
echo "On windows you can now run " $smoke_batch