//
// tester.h
//
// Author: M.R. van dootingh
// Date: febr 5 2010
//
// Very simple 'tester': just some nice output formatting
// Testing should be done by redirecting he output to a file
// and comparing that with a verified version of that file
//

#ifndef tester_h
#define tester_h

#include <iostream>

#define TEST( name ) \
	void name () { \
	cout << std::endl << "BEGIN TESTCASE " << #name << std::endl;
	
#define TEST_END }

#endif
