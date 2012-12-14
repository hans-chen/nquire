/**
 *       @file  main.c
 *      @brief  Demo
 *
 * This demo program will work on all models
 *
 *     @author  Lin Yuning (lyn), linyn@newlandcomputer.com
 *
 *   @internal
 *     Created  12/10/10
 *    Revision  1.0
 *    Compiler  gcc/g++
 *     Company  Fujian Newland Computer Co., Ltd.
 *   Copyright  Copyright (c) 2010, Lin Yuning
 *
 * This source code is released for free distribution under the terms of the
 * GNU General Public License as published by the Free Software Foundation.
 * =============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include "nlrf.h"

static int
get_operation(void)
{
	int ret;

	printf(	"-----RFID Demo-----\n"
			"0 Quit\n"
			"1 Read\n"
			"2 Write\n"
			"-------------------\n");
	scanf("%d", &ret);

	return ret;
}

static int
wait_card(int fd, struct nlrf_cardinfo *info)
{
	fd_set fds;
	int i, ret;
	char c = 0;

	printf("Detecting..... [Press 'q' to quit]\n");

	while (c != 'q') {
		ret = nlrf_send_querycardinfo(fd);
		if (ret != 0) {
			fprintf(stderr, "Send Card Query: %d\n", ret);
			return -1;
		}

		FD_ZERO(&fds);
		FD_SET(fd, &fds);
		FD_SET(0, &fds);

		ret = select(fd + 1, &fds, NULL, NULL, NULL);
		if (ret <= 0)
			continue;

		// No longer needs SIGALRM
		if (FD_ISSET(fd, &fds)) {
			ret = nlrf_fetch_querycardinfo(fd, info);
			if (ret == NLRF_OK) {
				printf("----------------------------\n");
				printf("Card ID   : ");
				for (i = 0; i < info->idlen; i++)
					printf("%02X", info->cardnum[i]);
				printf("\n");
				printf("Total sectors     : % 8d\n",
						info->nsector);
				printf("Blocks per sector : % 8d\n",
						info->nblock);
				printf("Bytes per block   : % 8d\n",
						info->blocksize);
				printf("----------------------------\n");

				return 0;
			}
		} else {
			c = getchar();
		}
	}

	return -1;
}

static int
authen_card(int fd, struct nlrf_cardinfo *info)
{
	unsigned char key[12];

	// Using default access key
	switch (info->cardtype) {
		case MIFARE_S50:
			memset(key, 0x0F, info->keysize);
			break;
		case AT88RF020:
			memset(key, 0x00, info->keysize);
			break;
		case MIFARE_ULTRALIGHT:
		case ICODE_2:
			break;
		default:
			return -1;
	}

	return nlrf_chkkey(fd, key, info->keysize);
}

static void
print_hex(const unsigned char *data, int len)
{
	int i;

	for (i = 0; i < len; i++)
		printf("%02X ", data[i]);
	printf("\n");
}

static int
read_card(int fd, struct nlrf_cardinfo *info)
{
	unsigned char *data;
	int i, j, ret;

	data = malloc(info->blocksize);

	for (i = 0; i < info->nsector; i++) {
		printf("Sector %d\n", i);
		for (j = 0; j < info->nblock; j++) {
			ret = nlrf_readblock(fd, i, j, data, info->blocksize);
			if (ret != NLRF_OK)
				printf("Error %d\n", ret);
			else
				print_hex(data, info->blocksize);
		}
	}

	free(data);

	return 0;
}

static int
is_writeable(struct nlrf_cardinfo *info, int sector, int block)
{
	switch (info->cardtype) {
		case MIFARE_S50:
			if (sector == 0 && block == 0)
				return 0;
			else
				return 1;
		case MIFARE_ULTRALIGHT:
			if (sector == 0)
				return 0;
			else
				return 1;
		case AT88RF020:
			if (block < 4)
				return 0;
			else
				return 1;
		case ICODE_2:
			return 1;
		default:
			return 0;
	}
}

static int
write_card(int fd, struct nlrf_cardinfo *info)
{
	unsigned char *data;
	int i, j, ret;

	data = malloc(info->blocksize);

	for (i = 0; i < info->nsector; i++) {
		printf("Sector %d\n", i);
		for (j = 0; j < info->nblock; j++) {
			// MIFARE ULTRALIGHT requires read ops before write
			if (info->cardtype == MIFARE_ULTRALIGHT) {
				ret = nlrf_readblock(fd, i, j, data,
						info->blocksize);
				memset(data, 0x00, info->blocksize);
			}

			if (!is_writeable(info, i, j)) {
				printf("Block %d is read-only\n", j);
				continue;
			}

			// Write different data onto different blocks
			memset(data, i * info->nblock + j, info->blocksize);
			ret = nlrf_writeblock(fd, i, j, data, info->blocksize);
			if (ret != NLRF_OK)
				printf("Error %d\n", ret);
			else
				printf("Write Block %d.....OK\n", j);
		}
	}

	free(data);

	return 0;
}

int
main(int argc, char **argv)
{
	struct nlrf_cardinfo info;
	int fd, ret;

	fd = nlrf_open("/dev/ttyS2");
	if (fd < 0) {
		fprintf(stderr, "Can't open rfid device\n");
		return EXIT_FAILURE;
	}

	switch (nlrf_get_modeltype(fd)) {
		case NLRF_MODEL_V1:
			printf("Model V1 Detected\n");
			break;
		case NLRF_MODEL_V2:
			printf("Model V2 Detected\n");
			break;
		case NLRF_MODEL_V3:
			printf("Model V3 Detected\n");
			break;
		default:
			break;
	}

	ret = get_operation();
	switch (ret) {
		case 1:
			while (wait_card(fd, &info) == 0) {
				authen_card(fd, &info);
				read_card(fd, &info);
				printf("Please remove card\n");
				sleep(5);
			}
			break;
		case 2:
			while (wait_card(fd, &info) == 0) {
				authen_card(fd, &info);
				write_card(fd, &info);
				printf("Please remove card\n");
				sleep(5);
			}
			break;
		default:
			printf("Invalid choice\n");
			break;
	}

	nlrf_close(fd);

	return EXIT_SUCCESS;
}
