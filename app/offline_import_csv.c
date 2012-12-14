/* import_csv.c - create a data and an index file from a csv file

Currently, the data file is more or less the same as the import file.

csv file format:

# comment lines start with '#'
# the first non comment is the header containing field definitions
# it should start with the barcode field and then the format field,
# then barcode definitions can follow.
# Starting and ending a value with a '"' would imply reading a string
# in which it is possible to use a comma.
# It is possible to use escape codes for using special charracters,
# e.g.: \x2c would print a ',' without having to use quotes.
#       \x22 would print a '\'
#       \x22 would print a '"' in a quoted string
# E.g:
barcode,format,product,price
732782387,norm_prod,cheese,"1,23"
987347612,special,edammer,0\x2c99

usage:
	create_csv_index <csv-file> <out.dat> <out.idx>

TODO:
	allow quotes around values, enabling use of the comma-char
	give progress in |,/,-,\ charracters
*/
#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <assert.h>
#include <stdint.h>

#define bool int
#define true 1
#define false 0

#define MAX_BARCODE_SIZE 512

//#define NDEBUG
#ifdef NDEBUG
#define DBG(...) do{}while(0)
#else
#define DBG(...) do{fprintf(stderr,"DEBUG: " __VA_ARGS__); fprintf(stderr,"\n");}while(0)
#endif

void print_help()
{
	printf("create an ordered index file for a csv file\n");
	printf("Usage: create_csv_index <target dir> <csv file>+\n");
	printf("\n");

}

// convert fields in a line to a standard format without quotes
// adjust the size of buf using realloc when it is to small
bool standardize_line( char** buf, size_t *bufsize, const char* src )
{
	char *dest = *buf;
	while( *src != 0 )
	{
		if( *src == '\"' )
		{
			++src;
			// copy a quoted field
			while( *src != 0 && !( *src == '\"' && *(src+1) != '\"' ) )
			{
				// when expanding charracters we need at most 3 more, and possibly the 0 char
				int n = dest-*buf;
				if( n+5 > *bufsize )
				{
					*bufsize = *bufsize*2;
					*buf = (char*)realloc(*buf,*bufsize);
					dest = &((*buf)[n]);
				}
				// convert oo-office (and ms-office?) type of escape for '"' in qouted fields:
				if( *src == ',' )
				{
					++src;
					*(dest++) = '\\';
					*(dest++) = 'x';
					*(dest++) = '2';
					*(dest++) = 'c';
				}
				else
				{
					if( *src == '\"' && *(src+1) == '\"' )
					{
						++src;
					}
					*(dest++)=*(src++);
				}
			}
			if( *src == '"' )
			{
				++src;
				if( *src != ',' && *src != '\0' )
				{
					// format error
					return false;
				}
			}
			else
			{
				// missing end-quote
				return false;
			}
			if( *src == ',' )
			{
				*dest=*src;
				++src;
				++dest;
			}
		}
		else
		{
			// copy a non-quoted field
			// copy a quoted field
			while( *src != 0 && *src != ',' )
			{
				int n = dest-*buf;
				// when expanding charracters we need at most 3 more, and possibly the 0 char
				if( n+5 > *bufsize )
				{
					*bufsize = *bufsize*2;
					*buf = (char*)realloc(*buf,*bufsize);
					dest = &((*buf)[n]);
				}
				*dest=*src;
				++dest;
				++src;
			}
			if( *src == ',' )
			{
				*dest=*src;
				++src;
				++dest;
			}
		}
	}
	*dest=0;
	return true;
}

static bool import_csv( 
		const char *csv_filename,
		const char *data_filename,
		const char *index_filename,
		bool *ordered)
{
	FILE *fcsv = fopen( csv_filename, "r" );
	if( fcsv == 0 )
	{
		fprintf(stderr,"Could not open csv file %s\n", csv_filename);
		exit(1);
	}

	FILE *fdat = fopen( data_filename, "w" );
	if( fdat == 0 )
	{
		fprintf(stderr,"Could not open data file %s\n", data_filename);
		exit(1);
	}

	FILE *fidx = fopen( index_filename, "w" );
	if( fidx == 0 )
	{
		fprintf(stderr,"Could not open index file %s\n", index_filename);
		exit(1);
	}

	size_t std_line_size = 1;
	char *std_line = (char*)malloc(std_line_size);

	int linenr = 0;
	size_t size = 512;
	char *buf = (char*)malloc(size);
	bool header_idx = false;
	*ordered = true;
	unsigned number_of_records = 0;
	char prev_bc[MAX_BARCODE_SIZE];
	prev_bc[0] = 0;
	while( !feof(fcsv) )
	{
		int n = getline(&buf,&size,fcsv);
		
		while( n>0 && (buf[n-1]=='\n' || buf[n-1]=='\r') )
		{
			n=n-1;
			buf[n] = 0;
		}
		linenr++;
		if( n>0 && buf[0]!='#' )
		{
			if( ! header_idx )
			{
				header_idx = true;
				fprintf(fdat,"%s\n", buf);
			}
			else
			{
				
				if( ! standardize_line( &std_line, &std_line_size, buf ) )
				{
					fprintf(stderr,"Error: format error on line %d\n", linenr);
					exit(1);
				}

				DBG("Standardized: \"%s\"", std_line);

				char bc[MAX_BARCODE_SIZE];
				char *end = (char*)memccpy( bc, std_line, ',', sizeof(prev_bc) );
				if(end!=0)
				{
					*(end-1) = 0;
				}
				else
				{
					fprintf(stderr,"Error: barcode on line %d exceeds maximum of 512 charracters\n", linenr);
					exit(1);
				}

				if( strcmp(prev_bc, bc) > 0 && *ordered )
				{
					fprintf(stderr,"Warning: file not ordered (first occurrence on line %d)\n", linenr);
					*ordered = false;
				}
				strcpy( prev_bc, bc );
				fprintf(fidx,"%08lx\n", ftell( fdat ));
				fprintf(fdat,"%s\n", std_line);
				number_of_records++;
			}
		}
	}

	fclose(fcsv);
	fclose(fdat);
	fclose(fidx);
	free(buf);
	free(std_line);

	return number_of_records;
}


static void get_barcode( char **bc , size_t *n, FILE *f, unsigned offset )
{
	DBG("get_barcode(%d)", offset);
	assert(f != 0 );
	if( fseek( f, offset, SEEK_SET ) != 0 )
	{
		fprintf(stderr, "get_barcode error: %s\n", strerror(errno));
		fflush(stderr);
		exit(1);
	}
	int r = getdelim( bc, n, ',', f );
	if(  r == -1 || r > MAX_BARCODE_SIZE )
	{
		fprintf(stderr, "Could not read barcode at offset %d\n", offset);
		exit(1);
	}

	bc[r]=0;
	DBG("got_barcode(%d)=%s", offset, *bc);
}

static FILE *fdat = 0;
static char *bc1 = 0;
static size_t n1 = 0;
static char *bc2 = 0;
static size_t n2 = 0;

static int compare_idx(const void *idx1, const void *idx2)
{
	static int count;

	DBG("compare_idx(%d,%d)", *(unsigned*)idx1, *(unsigned*)idx2);
	get_barcode( &bc1 , &n1, fdat, *(unsigned*)idx1 );
	get_barcode( &bc2, &n2, fdat, *(unsigned*)idx2 );

	if(count%1000 == 0)
	{
		printf("#compared=%d\n", count);
		fflush(stdout);
	}
	count++;
	return strcmp( bc1, bc2 );
}

static bool sort(
		const char *data_filename,
		const char *index_filename,
		unsigned number_of_records)
{
	// first read all indexes in a memory array:
	uint32_t *idx = (uint32_t*)calloc( number_of_records, sizeof(uint32_t) );
	if(idx==0)
	{
		fprintf(stderr,"Error: sorting failed - could not alloc memory for sorting");
	}
	else
	{
		// first read index in memory
		{
			DBG("using file %s", index_filename);
			FILE *fidx = fopen( index_filename, "r" );
			if( fidx == 0 )
			{
				fprintf(stderr,"Could not open index file %s\n", index_filename);
				exit(1);
			}
		
			unsigned i=0;
			while(!feof(fidx))
			{
				char buf[20];
				if(fgets( buf, sizeof(buf), fidx ))
				{
					sscanf(buf,"%8x",&(idx[i]));
					DBG("read %s = %x", buf , idx[i]);
					i++;
				}
			}
			if( i != number_of_records )
			{
				fprintf(stderr,"Database indexing internal error\n");
				exit(1);
			}
			fclose(fidx);
		}

		{
			// then sort:
			fdat = fopen( data_filename, "r" );
			if( fdat == 0 )
			{
				fprintf(stderr,"Could not open data file %s\n", index_filename);
				return 1;
			}
			qsort( idx, number_of_records, sizeof(idx[0]), compare_idx );
			fclose(fdat);
			free(bc1); bc1=0; n1=0;
			free(bc2); bc2=0; n2=0;
		}

		{
			// and dump to idx file:
			FILE *fidx = fopen( index_filename, "w" );
			if( fidx == 0 )
			{
				fprintf(stderr,"Could not open index file %s\n", index_filename);
				exit(1);
			}

			int i;
			for(i=0; i<number_of_records; i++)
			{
				fprintf(fidx,"%08x\n", idx[i]);
			}
			fclose(fidx);
		}
		free(idx);
	}
	return true;
}

int main( int argc, char *argv[] )
{
	if(argc<2)
	{
		print_help();
		return 1;
	}

	const char *target_dir = argv[1];

	int i;
	for( i=2; i<argc; i++ )
	{
		const char *csv_fpath = argv[i];
		
		const char *bn = basename(csv_fpath);
		unsigned l = strlen(bn);
		if( strcmp( bn + l-4, ".csv" ) != 0 )
		{
			fprintf(stderr,"Filename should end on '.csv' (case sensitive)\n");
			return 1;
		}

		char *tablename = (char*)malloc(l-3);
		if( tablename == 0 )
		{
			fprintf(stderr,"Malloc failed\n");
			return 1;
		}
		memcpy( tablename, bn, l-4 );
		tablename[l-4] = 0;

		unsigned length_fpath = strlen(target_dir) +1 + strlen(tablename) + 4 + 1;
		char *dat_fpath = (char*)malloc(length_fpath);
		if( dat_fpath == 0 )
		{
			fprintf(stderr,"Malloc failed\n");
			return 1;
		}
		sprintf(dat_fpath,"%s/%s.dat", target_dir, tablename);
		char *idx_fpath = (char*)malloc(length_fpath);
		if( idx_fpath == 0 )
		{
			fprintf(stderr,"Malloc failed\n");
			return 1;
		}
		sprintf(idx_fpath,"%s/%s.idx", target_dir, tablename);

		bool ordered = false;
		int number_of_records = import_csv( csv_fpath, dat_fpath, idx_fpath, &ordered );
		printf("#records=%d\n", number_of_records);
		fflush(stdout);

		if(!ordered)
		{
			printf("Unordered importfile: sorting...\n");
			sort( dat_fpath, idx_fpath, number_of_records );
		}

		free(tablename);
		free(dat_fpath);
		free(idx_fpath);
	}
	return 0;
}

