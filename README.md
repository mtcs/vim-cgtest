CGTest
======

[![Code Climate](https://codeclimate.com/github/mtcs/vim-cgtest/badges/gpa.svg)](https://codeclimate.com/github/mtcs/vim-cgtest)
[![Donate to MtCS](https://img.shields.io/gratipay/user/mtcs.svg?maxAge=2592000)](https://gratipay.com/~mtcs/)


__WARNING: This project is brand new and in alpha state, expect heavy changes.__

CGTest is a Vim plugin for working with ctest (from cmake) + gtest. It relies on internal vim
parsers and ctest command to execute tests and visualize results from XMLs from  CTest and GTest.

It is important to notice that both CTest and GTest have their own definition of 'test'. When we say
the we run a test binary file, we are referencing CTest tests, when referencing GTest tests we will say 'GTest
test'

Dependencies
------------

* CTest (CMake 2.8 +)
* GTest
* vim-dispatcher(?)

Commands
--------

* CGTest - Run all tests and show results in a new window
* CGTestAll - Run all tests using ctest without updating the internal database
* CGTestR <regex> - Run tests matching regular expression passed as parameter
* CGTestRefresh - Run all tests
* CGTestResults - Show test results in a new window
* CGTestResultsV - Show test results verbose in a new window
* CGTestInfoRefresh - Refresh test information

* CGTestF <regex> - Run GTest tests/testcases matching regular expression passed as parameter
* CGTestRefreshR <regex> - Run tests matching a regular expression (TODO)
* CGTestRefreshF <regex> - Run GTest/testcases tests matching a regular expression (TODO)
* CGTestRefreshBroaken - Run all failed tests (TODO)
* CGTestDash - Open test dashboard in a window (TODO)


