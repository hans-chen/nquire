//
// database.h
//
// Author: M.R. van dootingh
// Date: febr 5 2010
//

#ifndef database_h
#define database_h

#include <set>
#include <map>
#include <string>
#include <unistd.h>
#include <sys/stat.h>

class Tag_value
{
public:
	Tag_value( const std::string from_string );
	Tag_value( const std::string tag, const std::string value );

	bool fail()         const { return is_bad; }
	std::string tag()   const { return my_tag; }
	std::string value() const { return my_value; }	
	
	bool operator < ( const Tag_value& other ) const { return my_tag < other.my_tag; }
	bool operator == ( const Tag_value& other ) const { return my_tag == other.my_tag; }
	
private:
	bool is_bad;
	std::string my_tag;
	std::string my_value;
};


typedef std::set<Tag_value> Barcode_tags;

class Format
{
public:
	Format( const std::string format_name, const std::string format );

	void add_formatting( const std::string fmt ) const;
	std::string merge_tag_values( const Barcode_tags& tags ) const;

	bool operator < ( const Format& other ) const { return my_format_name < other.my_format_name; }
	bool operator == ( const Format& other ) const { return my_format_name == other.my_format_name; }

private:
	// find first occurrence of key in my_format_name considering escapes
	// So, finding "$" from 0 in "bla\$bla$bla" would return 8 (not 4)
	// When key is not found, npos is returned
	size_t find_first( std::string key, size_t from_pos ) const;

private:
	std::string my_format_name;
	// quite a dirty trick, otherwise you can't change the format when it is in a set
	mutable std::string my_format;
};


class Barcode_db
{
public:
	Barcode_db();
	void load( const std::string from_dir );
	const std::string lookup( const std::string code  );

	void load_barcodes( std::istream& bf );
	void load_formats( std::istream& ff );

private: // data

	typedef std::map< std::string, Barcode_tags > Known_barcodes;
	Known_barcodes my_known_barcodes;

	typedef std::set< Format > Known_formats;
	Known_formats my_known_formats;

#ifdef WIN32
	WIN32_FILE_ATTRIBUTE_DATA my_stat_barcodes_file;
	WIN32_FILE_ATTRIBUTE_DATA my_stat_formats_file;
#else
	struct stat my_stat_barcodes_file;
	struct stat my_stat_formats_file;
#endif

	std::string my_db_dir;
	std::string my_error_file_name;
};


#endif
