//
// database-tester.h
//
// Author: M.R. van dootingh
// Date: febr 5 2010
//

#include "database.h"
#include "misc.h"
#include "tester.h"

#include <iostream>
#include <sstream>

using namespace std;

TEST( test_Tag_value )
	Tag_value tv1( "bla=abc" );
	cout << "tv1(\"bla=abc\")=" << tv1.tag() << "," << tv1.value() << endl;
	
	Tag_value tv2( "little tag", "this is the value" );
	cout << "tv2=" << tv2.tag() << "," << tv2.value() << endl;
	cout << "tv2=" << (tv2.fail() ? "isbad" : "ok") << endl;
	
	Tag_value tv3( "erroneous tag" );
	cout << "tv3=" << (tv3.fail() ? "isbad" : "ok") << endl;
TEST_END

TEST( test_Format )
	Barcode_tags values1;
	values1.insert( Tag_value("format=f1") );
	values1.insert( Tag_value("tag.var1=variable value 1") );
	values1.insert( Tag_value("tag.var2=variable value 2") );
	
	Format f1( "f1", "\\${var1}='${var1}'\\n\\${var2}='${var2}'" );
	
	cout << "f1.merge_tag_values(values1)=" << f1.merge_tag_values(values1) << endl;
TEST_END

TEST( test_Barcode_db )
	Barcode_db bdb;

	stringstream bcd;
	bcd	<< "# comment and empty lines should be ignored" << endl << endl
		<< "[barcode1]" << endl
		<< "format=f1" << endl
		<< "tag.value1=this is barcode 1" << endl
		<< "tag.value2=content of value 2" << endl
		<< "[barcode2]" << endl
		<< "format=f2" << endl
		<< "tag.value1=this is barcode 2" << endl
		<< "tag.value2=content of value 2" << endl
		<< "[barcode3]" << endl
		<< "format=foutief" << endl
		<< "tag.value1=this is barcode 3" << endl
		<< "[]" << endl
		<< "format=onbekend" << endl;
	bdb.load_barcodes( bcd );
		
	stringstream fmd;
	fmd	<< "# comment and empty lines should be ignored" << endl << endl
		<< "[f1]" << endl
		<< "Format1:" << endl
		<< "the first value is \"${value1}\"\\n" << endl
		<< "and the second is \"${value2}\"" << endl
		<< "[f2]" << endl
		<< "Format2:" << endl
		<< "de eerste is \"${value1}\"\\n" << endl
		<< "de tweede is \"${value2}\"" << endl
		<< "[onbekend]" << endl
		<< "Formatting from format \"onbekend\"" << endl
		<< "[]" << endl
		<< "Onbekende format" << endl;
	bdb.load_formats( fmd );
	
	cout << "Barcode1:" << endl << bdb.lookup( "barcode1" ) << endl;
	cout << "Barcode2:" << endl << bdb.lookup( "barcode2" ) << endl;
	cout << "Barcode3:" << endl << bdb.lookup( "barcode3" ) << endl;
	cout << "Onbekende barcode:" << endl << bdb.lookup( "foutje" ) << endl;
TEST_END

int main(int argc, char *argv[] )
{
	set_log_file( "database-tester.log" );
	
	test_Tag_value();
	test_Format();
	test_Barcode_db();
	
	return 0;
}
