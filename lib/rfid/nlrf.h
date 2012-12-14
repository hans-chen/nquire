/**
 * @defgroup	nlrf_api		Application Interface
 */

/**
 * @defgroup	nlrf_example	Example files
 */

/**
 * @file		nlrf.h
 * @ingroup		nlrf_api
 *
 * @version		1.0.0
 * @author		Lin Yuning
 * @date		2009-07-21
 */

#ifndef _NLRF_H_
#define _NLRF_H_

#define NLRF_ERR_NODEV			1
#define NLRF_ERR_SETTTY			2
#define NLRF_ERR_BACKUPTTY		3
#define NLRF_ERR_RESTORETTY		4
#define NLRF_ERR_SEND			5
#define NLRF_ERR_RECV			6
#define NLRF_ERR_INVALID		7
#define NLRF_ERR_IGNORE_ME		8

#define NLRF_CARDNUM_LENGTH		4
#define NLRF_KEY_LENGTH			12
#define NLRF_BLOCK_NR			3
#define NLRF_SECTOR_NR			16
#define NLRF_BLOCK_SIZE			16
#define NLRF_SECTOR_SIZE		(NLRF_BLOCK_SIZE * NLRF_BLOCK_NR)

/**
 * @struct		nlrf_cardinfo
 * @ingroup		nlrf_api
 * @brief		Card information
 */
struct nlrf_cardinfo
{
	int nsector;	/**< @brief Total sector number */
	int nblock;		/**< @brief block number in one sector */
	int blocksize;	/**< @brief block storage size */
	char cardnum[NLRF_CARDNUM_LENGTH];	/**< @brief card id */
};

/**
 * @fn			int nlrf_open(const char *dev_name)
 * @ingroup		nlrf_api
 * @brief		Open RFID device
 *
 * @param[in]	dev_name	Device file path
 * @retval		fd			success
 * @retval		-NLRF_ERR_NODEV			open device failed/no device detected
 * @retval		-NLRF_ERR_BACKUPTTY		backup tty configuration failed
 * @retval		-NLRF_ERR_SETTTY		set tty configuration failed
 */
int nlrf_open(const char *dev_name);

/**
 * @fn			int nlrf_close(int fd)
 * @ingroup		nlrf_api
 * @brief		Close RFID device
 *
 * @param[in]	fd			file descriptor returned by function nlrf_open
 * @retval		0						success
 * @retval		-NLRF_ERR_RESTORETTY	restore tty configuration failed
 */
int nlrf_close(int fd);

/**
 * @fn			int nlrf_querycardinfo(int fd, struct nlrf_cardinfo *info)
 * @ingroup		nlrf_api
 * @brief		get card information
 *
 * @param[in]	fd			file descriptor returned by function nlrf_open
 * @param[out]	info		card information
 * @retval		0						success
 * @retval		-NLRF_ERR_SEND			send command failed
 * @retval		-NLRF_ERR_RECV			receive response failed
 */
int nlrf_querycardinfo(int fd, struct nlrf_cardinfo *info);

/**
 * @fn			int nlrf_send_querycardinfo(int fd)
 * @ingroup		nlrf_api
 * @brief		asynchronous query card information
 *
 * @param[in]	fd			file descriptor returned by function nlrf_open
 * @retval		0						success
 * @retval		-NLRF_ERR_SEND			send command failed
 */
int nlrf_send_querycardinfo(int fd);

/**
 * @fn			int nlrf_fetch_querycardinfo(int fd, struct nlrf_cardinfo *info)
 * @ingroup		nlrf_api
 * @brief		asyhchronous fetch card information
 *
 * @param[in]	fd			file descriptor returned by function nlrf_open
 * @param[out]	info		card information
 * @retval		0						success
 * @retval		-NLRF_ERR_IGNORE_ME		"no card" response received (ignore it)
 * @retval		-NLRF_ERR_INVALID		receive response failed
 */
int nlrf_fetch_querycardinfo(int fd, struct nlrf_cardinfo *info);

/**
 * @fn			int nlrf_chkkey(int fd, const unsigned char *key, int length)
 * @ingroup		nlrf_api
 * @brief		set access password
 *
 * @param[in]	fd			file descriptor returned by function nlrf_open
 * @param[in]	key			access password
 * @param[in]	length		password length
 * @retval		0						success
 * @retval		-NLRF_ERR_INVALID		invalid parameter
 * @retval		-NLRF_ERR_SEND			send command failed
 * @retval		-NLRF_ERR_RECV			receive response failed
 * @attention	call this function before read/write card
 */
int nlrf_chkkey(int fd, const unsigned char *key, int length);

/**
 * @fn			int nlrf_setkey(int fd, int sector,
 * 						const unsigned char *oldkey,
 *						const unsigned char *newkey, int length)
 * @ingroup		nlrf_api
 * @brief		change access password
 *
 * @param[in]	fd			file descriptor returned by function nlrf_open
 * @param[in]	sector		sector id
 * @param[in]	oldkey		old password
 * @param[in]	newkey		new password
 * @param[in]	length		password length
 * @retval		0						command send success
 * @retval		-NLRF_ERR_INVALID		invalid parameter
 * @retval		-NLRF_ERR_SEND			send command failed
 * @retval		-NLRF_ERR_RECV			receive response failed
 * @attention	each sector has different access password
 */
int nlrf_setkey(int fd, int sector, const unsigned char *oldkey,
		const unsigned char *newkey, int length);

/**
 * @fn			int nlrf_readblock(int fd, int sector, int block,
 *						unsigned char *data, int length);
 * @ingroup		nlrf_api
 * @brief		read data
 *
 * @param[in]	fd			file descriptor returned by function nlrf_open
 * @param[in]	sector		sector id
 * @param[in]	block		block id (when read whole sector: id = total blocks in one sector)
 * @param[out]	data		data buffer
 * @param[in]	length		data length
 * @retval		0						success
 * @retval		-NLRF_ERR_INVALID		invalid parameter
 * @retval		-NLRF_ERR_SEND			send command failed
 * @retval		-NLRF_ERR_RECV			receive response failed
 * @attention	will block on unset/bad access password, please remove card from card reader and wait 3+ seconds
 */
int nlrf_readblock(int fd, int sector, int block, unsigned char *data,
		int length);

/**
 * @fn			int nlrf_writeblock(int fd, int sector, int block,
 *						const unsigned char *data, int length);
 * @ingroup		nlrf_api
 * @brief		write data
 *
 * @param[in]	fd			file descriptor returned by function nlrf_open
 * @param[in]	sector		sector id
 * @param[in]	block		block id (can't write whole sector)
 * @param[in]	data		data buffer
 * @param[in]	length		data length
 * @retval		0						success
 * @retval		-NLRF_ERR_INVALID		invalid parameter
 * @retval		-NLRF_ERR_SEND			send command failed
 * @retval		-NLRF_ERR_RECV			receive response failed
 * @attention	will block on unset/bad access password, please remove card from card reader and wait 3+ seconds
 */
int nlrf_writeblock(int fd, int sector, int block, const unsigned char *data,
		int length);

#endif
