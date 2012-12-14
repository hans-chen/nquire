//
// misc-tester.cpp
//
// Author: M.R. van dootingh
// Date: febr 5 2010
//

#include "misc.h"
#include "tester.h"

#include <iostream>

using namespace std;

TEST(test_bytes_to_text)
	cout << "\\n='" << bytes_to_text( "\n" ) << "'" << endl;
	cout << "\\r='" << bytes_to_text( "\r" ) << "'" << endl;
	cout << "\\t='" << bytes_to_text( "\t" ) << "'" << endl;
	cout << "\\e='" << bytes_to_text( "\x1d" ) << "'" << endl;
	cout << "\\[='" << bytes_to_text( "[" ) << "'" << endl;
	cout << "\\]='" << bytes_to_text( "]" ) << "'" << endl;
	cout << "\\$='" << bytes_to_text( "$" ) << "'" << endl;
	cout << "\\#='" << bytes_to_text( "#" ) << "'" << endl;
	cout << "\\\\='" << bytes_to_text( "\\" ) << "'" << endl;
	cout << "\\x1f='" << bytes_to_text( "\x1f" ) << "'" << endl;
	cout << "\\x20='" << bytes_to_text( "\x20" ) << "'" << endl;
	cout << "\\x7f='" << bytes_to_text( "\x7f" ) << "'" << endl;
	cout << "\\x80='" << bytes_to_text( "\x80" ) << "'" << endl;
TEST_END

TEST(test_text_to_bytes)
	cout << bytes_to_text( text_to_bytes( "newline: \\n" ) ) << endl;
	cout << bytes_to_text( text_to_bytes( "return: \\r" ) ) << endl;
	cout << bytes_to_text( text_to_bytes( "tab: \\t" ) ) << endl;
	cout << bytes_to_text( text_to_bytes( "escape: \\e" ) ) << endl;
	cout << bytes_to_text( text_to_bytes( "brackets: \\[\\]" ) ) << endl;
	cout << bytes_to_text( text_to_bytes( "dollar: \\$" ) ) << endl;
	cout << bytes_to_text( text_to_bytes( "hekje: \\#" ) ) << endl;
	cout << bytes_to_text( text_to_bytes( "backslash: \\\\" ) ) << endl;
	cout << bytes_to_text( text_to_bytes( "hex codes: \\x03\\x80\\xa0\\xff" ) ) << endl;
TEST_END

TEST(test_get_local_ip_addresses)
	std::vector<string> addresses = get_local_ip_addresses();
	for(size_t i=0; i<addresses.size(); i++)
	{
		cout << "addr[" << i << "]=" << addresses[i] << endl;
	}
TEST_END

int main( int argc, char *argv[] )
{
	test_bytes_to_text();
	test_text_to_bytes();
	test_get_local_ip_addresses();
}
