/**
 * @addtogroup nlrf_api		Application Interface
 * @{
 */

/**
 *       @file  nlrf.h
 *      @brief  RFID API
 *
 * API for RFID reader
 *
 *     @author  Lin Yuning (lyn), linyn@newlandcomputer.com
 *
 *   @internal
 *     Created  04/12/11
 *    Revision  1.2.1
 *    Compiler  gcc/g++
 *     Company  Fujian Newland Computer Co., Ltd.
 *   Copyright  Copyright (c) 2011, Lin Yuning
 *
 * This source code is released for free distribution under the terms of the
 * GNU General Public License as published by the Free Software Foundation.
 * =============================================================================
 */

#ifndef _NLRF_H_
#define _NLRF_H_

#define MAX_CARDNUM_LENGTH	8 /**< @brief Maxinum card id length */

/**
 * @enum  RFIDResponse
 *
 * @brief operation responses
 */
enum RFIDResponse{
	NLRF_OK = 0,		 /**< @brief operation success */
	NLRF_ERR_NODEV = -1,	 /**< @brief rfid device does not exist */
	NLRF_ERR_NOCARD = -2,	 /**< @brief no rfid card detected */
	NLRF_ERR_WRONGKEY = -3,	 /**< @brief invalid authen key */
	NLRF_ERR_CARDORKEY = -4, /**< @brief no card detected or invalid key */
	NLRF_ERR_IGNORE_ME = -5, /**< @brief just ignore this error */
	NLRF_ERR_INVALID = -6,	 /**< @brief invalid input parameter */
	NLRF_ERR_SETTTY = -7,	 /**< @brief error while setting tty */
	NLRF_ERR_BACKUPTTY = -8, /**< @brief error while backuping tty */
	NLRF_ERR_RESTORETTY = -9,/**< @brief error while restore tty */
	NLRF_ERR_UNKNOWN = -10,	 /**< @brief unknown error occurred */
};

/**
 * @enum  RFIDModelType
 *
 * @brief model types
 */
enum RFIDModelType {
	/**
	 * @brief Model V1
	 * 
	 * Supported card types:
	 *   - ::MIFARE_S50
	 *   .
	 */
	NLRF_MODEL_V1,

	/**
	 * @brief Model V2
	 * 
	 * Supported card types:
	 *   - ::MIFARE_S50
	 *   .
	 */
	NLRF_MODEL_V2,

	/**
	 * @brief Model V3
	 * 
	 * Supported card types:
	 *   - ::MIFARE_S50
	 *   - ::MIFARE_ULTRALIGHT
	 *   - ::AT88RF020
	 *   - ::ICODE_2
	 *   .
	 */
	NLRF_MODEL_V3,
};

/**
 * @enum  RFIDCardType
 *
 * @brief card types
 */
enum RFIDCardType {
	/**
	 * @brief MIFARE S50
	 * 
	 * Spec:
	 *   - Protocol          : ISO14443_TYPE_A
	 *   - Card ID length    : 4
	 *   - Sectors           : 16
	 *   - Blocks per sector : 3
	 *   - Bytes per block   : 16
	 *   - Access key length : 12
	 *   .
	 */
	MIFARE_S50		= 0x01,

	/**
	 * @brief MIFARE Ultralight
	 * 
	 * Spec:
	 *   - Protocol          : ISO14443_TYPE_A
	 *   - Card ID length    : 4
	 *   - Sectors           : 4
	 *   - Blocks per sector : 4
	 *   - Bytes per block   : 4
	 *   - Access key length : not required
	 *   .
	 */
	MIFARE_ULTRALIGHT	= 0x02,

	/**
	 * @brief AT88RF020
	 * 
	 * Spec:
	 *   - Protocol          : ISO14443_TYPE_B
	 *   - Card ID length    : 4
	 *   - Sectors           : 1
	 *   - Blocks per sector : 32
	 *   - Bytes per block   : 8
	 *   - Access key length : 8
	 *   .
	 */
	AT88RF020		= 0x04,

	/**
	 * @brief ICODE 2
	 * 
	 * Spec:
	 *   - Protocol          : ISO15693
	 *   - Card ID length    : 8
	 *   - Sectors           : 1
	 *   - Blocks per sector : 28
	 *   - Bytes per block   : 4
	 *   - Access key length : not required
	 *   .
	 */
	ICODE_2			= 0x08,
};

/**
 * @struct	nlrf_cardinfo
 *
 * @brief	RFID card information
 */
struct nlrf_cardinfo {
	int cardtype;	 /**< @brief card type */
	int nsector;	 /**< @brief total sectors */
	int nblock;	 /**< @brief blocks per sector */
	int blocksize;	 /**< @brief bytes per block */
	int keysize;	 /**< @brief access key length */
	int idlen;	 /**< @brief card id length */
	unsigned char cardnum[MAX_CARDNUM_LENGTH];	 /**< @brief card id */
};

/**
 * @brief   Open RFID device
 *
 * @param[in]	dev_name	device file path
 *
 * @return  file descriptor for RFID device
 * @retval  fd
 * @retval  ::NLRF_ERR_NODEV
 * @retval  ::NLRF_ERR_BACKUPTTY
 * @retval  ::NLRF_ERR_SETTTY
 */
int nlrf_open(const char *dev_name);

/**
 * @brief   Close RFID device
 *
 * @param[in]	fd	file descriptor
 *
 * @return	operation result
 * @retval	::NLRF_OK
 * @retval	::NLRF_ERR_RESTORETTY
 */
int nlrf_close(int fd);

/**
 * @brief   Query card information
 *
 * @param[in]	fd	file descriptor
 * @param[out]	info	card information
 *
 * @return	operation result
 * @retval	::NLRF_OK
 * @retval	::NLRF_ERR_NODEV
 * @retval	::NLRF_ERR_NOCARD
 */
int nlrf_querycardinfo(int fd, struct nlrf_cardinfo *info);

/**
 * @brief   Asynchronous query card information
 *
 * @param[in]	fd	file descriptor
 *
 * @return	operation result
 * @retval	::NLRF_OK
 * @retval	::NLRF_ERR_NODEV
 *
 */
int nlrf_send_querycardinfo(int fd);

/**
 * @brief   Asynchronous fecth card information
 *
 * @param[in]	fd	file descriptor
 * @param[out]	info	card information
 *
 * @return	operation result
 * @retval	::NLRF_OK
 * @retval	::NLRF_ERR_NODEV
 * @retval	::NLRF_ERR_INVALID
 * @retval	::NLRF_ERR_IGNORE_ME
 * @retval	::NLRF_ERR_NOCARD
 */
int nlrf_fetch_querycardinfo(int fd, struct nlrf_cardinfo *info);

/**
 * @brief	Set access key
 *
 * @param[in]	fd	file descriptor
 * @param[in]	key	access key
 * @param[in]	length	access key length
 *
 * @return	operation result
 * @retval	::NLRF_OK
 * @retval	::NLRF_ERR_NODEV
 * @retval	::NLRF_ERR_INVALID
 * @retval	::NLRF_ERR_NOCARD
 * @retval	::NLRF_ERR_WRONGKEY
 * @retval	::NLRF_ERR_CARDORKEY
 *
 * @attention
 * Call this function before ::nlrf_readblock and ::nlrf_writeblock
 */
int nlrf_chkkey(int fd, const unsigned char *key, int length);

/**
 * @brief	Change access key for the specified sector
 *
 * @param[in]	fd	file descriptor
 * @param[in]	sector	sector id
 * @param[in]	oldkey	old access key
 * @param[in]	newkey	new access key
 * @param[in]	length	access key length
 *
 * @return	operation result
 * @retval	::NLRF_OK
 * @retval	::NLRF_ERR_NODEV
 * @retval	::NLRF_ERR_INVALID
 * @retval	::NLRF_ERR_NOCARD
 * @retval	::NLRF_ERR_WRONGKEY
 * @retval	::NLRF_ERR_CARDORKEY
 *
 * @attention
 * Each sector requires its own access key
 */
int nlrf_setkey(int fd, int sector, const unsigned char *oldkey,
		const unsigned char *newkey, int length);

/**
 * @brief	Read data
 *
 * @param[in]	fd	file descriptor
 * @param[in]	sector	sector id
 * @param[in]	block	block id
 * @param[out]	data	read data buffer
 * @param[in]	length	data length
 *
 * @return	operation result
 * @retval	::NLRF_OK
 * @retval	::NLRF_ERR_NODEV
 * @retval	::NLRF_ERR_INVALID
 * @retval	::NLRF_ERR_NOCARD
 * @retval	::NLRF_ERR_WRONGKEY
 * @retval	::NLRF_ERR_CARDORKEY
 */
int nlrf_readblock(int fd, int sector, int block, unsigned char *data,
		int length);

/**
 * @brief	Write data
 *
 * @param[in]	fd	file descriptor
 * @param[in]	sector	sector id
 * @param[in]	block	block id
 * @param[in]	data	write data buffer
 * @param[in]	length	data length
 *
 * @return  operation result
 * @retval	::NLRF_OK
 * @retval	::NLRF_ERR_NODEV
 * @retval	::NLRF_ERR_INVALID
 * @retval	::NLRF_ERR_NOCARD
 * @retval	::NLRF_ERR_WRONGKEY
 * @retval	::NLRF_ERR_CARDORKEY
 */
int nlrf_writeblock(int fd, int sector, int block, const unsigned char *data,
		int length);

/**
 * @brief	Get current model type
 *
 * @param[in]	fd	file descriptor
 *
 * @return	Model Type
 * @retval	::NLRF_MODEL_V1
 * @retval	::NLRF_MODEL_V2
 * @retval	::NLRF_MODEL_V3
 * @retval	::NLRF_ERR_NODEV
 */
int nlrf_get_modeltype(int fd);

/**
 * @brief	Set detectable card types
 *
 * @param[in]	fd		file descriptor
 * @param[in]	cardtype	detectable card types
 *
 * @return	operation result
 * @retval	::NLRF_OK
 * @retval	::NLRF_ERR_INVALID
 *
 * @attention
 * Only work on ::NLRF_MODEL_V3, using bitwise-or to set multiple card types,
 * ex: MIFARE_S50 | AT88RF020. Default action is detecting all types of cards
 */
int nlrf_set_cardtype(int fd, int cardtype);

#endif

/**
 * @}
 */
