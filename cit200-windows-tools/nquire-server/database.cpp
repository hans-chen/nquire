//
// database.cpp
//
// Author: M.R. van dootingh
// Date: febr 5 2010
//

#ifdef WIN32
#include <Windows.h>
#endif

#include "database.h"
#include "misc.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>

#include <map>
#include <string>
#include <iostream>
#include <fstream>

using namespace std;

#define FORMATS_FILENAME "formats.ini"
#define BARCODES_FILENAME "barcodes.ini"



// ***************************************************************************

Tag_value::Tag_value( const std::string tag, const std::string value )
:   is_bad( false )
,   my_tag( tag )
,   my_value( value )
{
}


Tag_value::Tag_value( const std::string from )
:   is_bad( false )
{
	unsigned i = from.find('=');
	if( i == string::npos )
		is_bad = true;
	else
	{
		my_tag = from.substr(0, i);
		my_value = from.substr(i+1);
	}
}


// ***************************************************************************


Format::Format( const string format_name, const string format )
:   my_format_name( format_name )
,   my_format( format )
{
}

// find first considering escapes
unsigned Format::find_first( string key, unsigned from_pos ) const
{
	unsigned i=from_pos;
	while( i<my_format.size()-1 )
	{
		if( my_format[i] == '\\' )
			i+=2;
		else if( my_format.compare( i, key.size(), key ) == 0 )
		{
			return i;
		}
		else
			i++;
	}
	return string::npos;
}
	
void Format::add_formatting( const std::string fmt )  const
{ 
	my_format += fmt; 
}

std::string Format::merge_tag_values( const Barcode_tags& tags ) const
{
	string result;
	unsigned i=0;
	while( i<my_format.size() )
	{
		unsigned begin = find_first( "${", i );
		if(begin == string::npos)
		{
			result += my_format.substr(i);
			i=my_format.size();
		}
		else
		{
			result += my_format.substr(i,begin-i);
			begin += 2;
			unsigned end = find_first( "}", begin );
			if( end == string::npos )
			{
				LOG_WRN( "Format error: '${' not closed in format '" 
					<< my_format_name << "' at position " << begin );
				// TODO: use hardcoded sensible default
				result += my_format.substr(i);
				i=my_format.size();
			}
			else
			{
				string tag = string("tag.") + my_format.substr( begin, end-begin );
				string value;
				Barcode_tags::const_iterator tv_it = tags.find( Tag_value(tag,"") );
				if( tv_it == tags.end() )
				{
					LOG_WRN( "Tag '" << tag << "' from format '" << my_format_name 
						<< "' not found: using empty string." );
				}
				else
				{
					result += tv_it->value();
				}
				i=end+1;
			}
		}
	}
	return result;
}

// ***************************************************************************


Barcode_db::Barcode_db()
{
	memset(&my_stat_barcodes_file,0,sizeof(my_stat_barcodes_file));
	memset(&my_stat_formats_file,0,sizeof(my_stat_formats_file));
}

void Barcode_db::load_barcodes( istream& bf )
{
	pair<Known_barcodes::iterator,bool> it_ok(my_known_barcodes.end(),false);
	int lnr = 0;
	while( !bf.eof() )
	{
		lnr++;
		string l;
		getline( bf, l );
		if( *l.rbegin() == '\r' )
			l.resize( l.size()-1 );
		LOG_DMP( "line=\"" << l << "\"" );
		if( l.size() == 0 || l[0]=='#' )
		{  
			// skip empty or comment line
			LOG_DMP("Skipping comment or empty line #" << lnr << ": " << l );
		}
		else if( l.size()>0 && l[0]=='[' )
		{
			if( l[l.size()-1]==']' )
			{
				string barcode = l.substr( 1, l.size()-2 );
				LOG_DBG( "Reading barcode definition: \"" << barcode << "\"" );
				it_ok = my_known_barcodes.insert( make_pair( barcode, Barcode_tags() ) );
			}
			else
			{
				LOG_WRN("Line " << lnr << " \"" << l << "\" begins with '[' but does not end with ']': line is skipped!" );
				it_ok.second = false;
			}
		}
		else if( it_ok.second )
		{
			LOG_DBG( "Tag_value line #" << lnr << ": \"" << l << "\"" );
			Tag_value tv(l);
			if( tv.fail() )
			{
				LOG_WRN("Incorrect tag-value \"" << l << "\" at line " << lnr << " (skipped).");
			}
			else
				it_ok.first->second.insert( tv );
		}
		else
		{
			LOG_WRN( "Tag-value at line #" << lnr << " \"" << l << "\" outsite barcode definition: ignored" );
		}
	}
	LOG_DBG("Ready reading barcode definitions");
}

void Barcode_db::load_formats( istream& ff )
{
	pair< Known_formats::iterator, bool > it_ok( my_known_formats.end(), false );
	int lnr = 0;
	while( !ff.eof() )
	{
		lnr++;
		string l;
		getline( ff, l );
		if( *l.rbegin() == '\r' )
			l.resize( l.size()-1 );
		if( l.size()==0 || l[0]=='#' )
		{  
			// skip comment line
			LOG_DMP("Skipping comment or empty line #" << lnr << ": " << l );
		}
		else if( l.size()>0 && l[0]=='[' )
		{
			if( l[l.size()-1]!=']' )
			{
				LOG_WRN( "Format line \"" << l << "\" at " << lnr << " begins with '[' but does not end with ']'")
				LOG_WRN( "line " << lnr << " and next lines are skipped until a valid format definitions is recognized." );
				LOG_INF( "Recommend using '\\[' when using a '[' in the formatting." );
				
				it_ok.second = false;
			}
			else
			{
				string tag = l.substr( 1, l.size()-2 );
				LOG_DBG("Reading format: \"" << tag << "\"");
				it_ok = my_known_formats.insert( Format( tag, "" ) );
			}
		}
		else if( it_ok.second )
		{
			LOG_DBG(l);
			it_ok.first->add_formatting( l );
		}
		else
		{
			LOG_WRN( "Unrecognized formats \"" << l << "\" at line " << lnr);
		}
	}
	LOG_DBG("Ready reading formats");
}

void Barcode_db::load( const string from_dir )
{
	my_db_dir = from_dir == "" ? "." : from_dir;

	// load barcode definitions when file is changed
	bool bc_changed = false;
	string bc_filename = my_db_dir + "/" + BARCODES_FILENAME;
#ifdef WIN32
	WIN32_FILE_ATTRIBUTE_DATA stat_barcodes_file;
	memset( &stat_barcodes_file, 0, sizeof stat_barcodes_file);
	if(GetFileAttributesEx( bc_filename.c_str(), GetFileExInfoStandard, &stat_barcodes_file)==0)
	{
		LOG_WRN( "Could not stat " << bc_filename << ": force reloading.");
		bc_changed = true;
	}
	else
	{
		bc_changed = memcmp( &stat_barcodes_file.ftLastWriteTime,
					&my_stat_barcodes_file.ftLastWriteTime,
					sizeof stat_barcodes_file.ftLastWriteTime ) != 0;
	}
#else
	struct stat stat_barcodes_file;
	memset(&stat_barcodes_file,0,sizeof(stat_barcodes_file));
	stat(bc_filename.c_str(), &stat_barcodes_file);
	bc_changed = stat_barcodes_file.st_mtime != my_stat_barcodes_file.st_mtime ||
			stat_barcodes_file.st_ctime != my_stat_barcodes_file.st_ctime;
#endif
	if( bc_changed )
	{
		LOG_INF( "Reloading " << bc_filename);
		my_stat_barcodes_file = stat_barcodes_file;

		// (re)load file
		my_known_barcodes.clear();
		ifstream bf(bc_filename.c_str());
		if( bf.fail() )
			throw string("ERROR: barcodes file \"") + bc_filename + "\" not found.";
		load_barcodes( bf );
		bf.close();
	}

	// load formats from file:
	bool ff_changed = false;
	string fm_filename = my_db_dir + "/" + FORMATS_FILENAME;
#ifdef WIN32
	WIN32_FILE_ATTRIBUTE_DATA stat_formats_file;
	memset( &stat_formats_file, 0, sizeof stat_formats_file);
	if(GetFileAttributesEx( fm_filename.c_str(), GetFileExInfoStandard, &stat_formats_file)==0)
	{
		LOG_WRN( "Could not stat " << fm_filename << ": force reloading.");
		ff_changed = true;
	}
	else
	{
		ff_changed = memcmp( &stat_formats_file.ftLastWriteTime,
					&my_stat_formats_file.ftLastWriteTime,
					sizeof stat_formats_file.ftLastWriteTime ) != 0;
	}
#else
	struct stat stat_formats_file;
	memset(&stat_formats_file,0,sizeof(stat_formats_file));
	stat(fm_filename.c_str(), &stat_formats_file);
	ff_changed = stat_formats_file.st_mtime != my_stat_formats_file.st_mtime ||
				stat_formats_file.st_ctime != my_stat_formats_file.st_ctime;
#endif
	if( ff_changed )
	{
		string ff_filename = string(my_db_dir) + "/" + FORMATS_FILENAME;
		LOG_INF( "Reloading " << ff_filename );
		my_stat_formats_file = stat_formats_file;

		// (re)load formats
		my_known_formats.clear();
		ifstream ff(ff_filename.c_str());
		if( ff.fail() )
			throw string("ERROR: format file \"") + ff_filename + "\" not found";

		load_formats( ff );
	
		ff.close();
	}
}

	
const string Barcode_db::lookup( const string code )
{
	LOG_DMP("Looking up barcode \"" << code << "\"");
	
	// find barcode:
	Known_barcodes::iterator bc_it = my_known_barcodes.find( code );
	if( bc_it == my_known_barcodes.end() )
	{
		LOG_WRN( "Barcode \"" << code << "\" not defined in database." );
		bc_it = my_known_barcodes.find( "" );
		if( bc_it == my_known_barcodes.end() )
			throw string("Unknown barcode ") + code 
					+ " and no backup barcode [] available";
	}
	LOG_DMP("Barcode found");
	// get name of formatting from barcode tags:
	string format_name;
	Barcode_tags::iterator tv_it = bc_it->second.find(Tag_value( "format", "" ));
	if( tv_it == bc_it->second.end() )
	{
		LOG_WRN( "No format specified for barcode '" << code << "'" );
		format_name = "";
	}
	else
	{
		format_name = tv_it->value();
	}
	LOG_DMP("Using format \"" << format_name << "\"");

	// find formatting:
	Known_formats::iterator fm_it = my_known_formats.find( Format(format_name,"") );
	if( fm_it == my_known_formats.end() )
	{
		fm_it = my_known_formats.find( Format("","") );
		if( fm_it == my_known_formats.end() )
			throw string("Unknown format for barcode ") + code 
						+ " and no backup format [] available";
		LOG_WRN( "Unknown format for barcode '" << code << "': using default." );
	}
	else
	{
		LOG_DMP("Format \"" << format_name << "\" found");
	}
	
	// merge barcode with formatting
	return fm_it->merge_tag_values( bc_it->second );	
}


// vi: ft=c++ ts=4 sw=4
