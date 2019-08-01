#!/usr/bin/env bash

set -uo pipefail

TESTS="tests.cry"

RESULTS=()

test () {
  local exp_ret=$1  # expected return code
  local arg=$2      # test argument

  echo "========================================================================"
  echo $arg
  echo "------------------------------------------------------------------------"

  cryptol -e -c ":l $TESTS" -c ":set ascii=on" -c "$arg" \
    | grep -v 'Loading module'
  ret=`echo $?`

  echo "------------------------------------------------------------------------"
  if [ $ret -eq $exp_ret ] && [ '0' -eq $exp_ret ]; then
    res="PASS: $arg"

  elif [ $ret -eq $exp_ret ] && [ '1' -eq $exp_ret ]; then
    res="XFAIL: $arg"

  else
    res="FAIL: $arg"
  fi

  echo $res
  RESULTS+=("$res")
}

# Make sure the type constraints in the 'md5' module pick these
# type arguments automatically.

# Should pass.
test 0 'test /*`{l=1}*/ inEmpty         outEmpty'
test 0 'test /*`{l=1}*/ inA             outA'
test 0 'test /*`{l=1}*/ inAbc           outAbc'
test 0 'test /*`{l=1}*/ inMessageDigest outMessageDigest'
test 0 'test /*`{l=1}*/ inLower         outLower'
test 0 'test /*`{l=2}*/ inAlphaNum      outAlphaNum'
test 0 'test /*`{l=2}*/ inDigits        outDigits'
test 0 'test /*`{l=2}*/ inPadding       outPadding'

# Should fail.
test 1 'test`{l=0} inEmpty         outEmpty'
test 1 'test`{l=0} inA             outA'
test 1 'test`{l=0} inAbc           outAbc'
test 1 'test`{l=0} inMessageDigest outMessageDigest'
test 1 'test`{l=0} inLower         outLower'
test 1 'test`{l=1} inAlphaNum      outAlphaNum'
test 1 'test`{l=1} inDigits        outDigits'
test 1 'test`{l=1} inPadding       outPadding'

test 1 'test`{l=2} inEmpty         outEmpty'
test 1 'test`{l=2} inA             outA'
test 1 'test`{l=2} inAbc           outAbc'
test 1 'test`{l=2} inMessageDigest outMessageDigest'
test 1 'test`{l=2} inLower         outLower'
test 1 'test`{l=3} inAlphaNum      outAlphaNum'
test 1 'test`{l=3} inDigits        outDigits'
test 1 'test`{l=3} inPadding       outPadding'

echo -e "\nRESULTS:"
for i in "${RESULTS[@]}"; do
  echo $i
done
