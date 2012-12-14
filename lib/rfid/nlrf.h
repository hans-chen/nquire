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
 * @version		1.1.0
 * @author		Lin Yuning
 * @date		2010-02-02
 */

#ifndef _NLRF_H_
#define _NLRF_H_

enum {
	NLRF_OK = 0,
	NLRF_ERR_NODEV,
	NLRF_ERR_NOCARD,
	NLRF_ERR_WRONGKEY,
	NLRF_ERR_CARDORKEY,
	NLRF_ERR_IGNORE_ME,
	NLRF_ERR_INVALID,
	NLRF_ERR_SETTTY,
	NLRF_ERR_BACKUPTTY,
	NLRF_ERR_RESTORETTY,
	NLRF_ERR_UNKNOWN,
};

enum {
	NLRF_MODEL_V1,
	NLRF_MODEL_V2,
	NLRF_MODEL_UNKNOWN,
};

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
 * @retval		-NLRF_ERR_NODEV			device is not ready
 * @retval		-NLRF_ERR_NOCARD		no card detected
 */
int nlrf_querycardinfo(int fd, struct nlrf_cardinfo *info);

/**
 * @fn			int nlrf_send_querycardinfo(int fd)
 * @ingroup		nlrf_api
 * @brief		asynchronous query card information
 *
 * @param[in]	fd			file descriptor returned by function nlrf_open
 * @retval		0						success
 * @retval		-NLRF_ERR_NODEV			device is not ready
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
 * @retval		-NLRF_ERR_INVALID		device is not in query mode
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
 * @retval		-NLRF_ERR_NODEV			device is not ready
 * @retval		-NLRF_ERR_IGNORE_ME		just ignore it and resend nlrf_send_querycardinfo (For Model V1)
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
 * @retval		-NLRF_ERR_NODEV			device is not ready
 * @retval		-NLRF_ERR_WRONGKEY		wrong access key
 * @retval		-NLRF_ERR_NOCARD		no card detected
 * @retval		-NLRF_ERR_CARDORKEY		no card or wrong access key (For Model V1)
 * @attention	each sector has individual access password
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
 * @retval		-NLRF_ERR_NODEV			device is not ready
 * @retval		-NLRF_ERR_WRONGKEY		wrong access key
 * @retval		-NLRF_ERR_NOCARD		no card detected
 * @retval		-NLRF_ERR_CARDORKEY		no card or wrong access key (For Model V1)
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
 * @retval		-NLRF_ERR_NODEV			device is not ready
 * @retval		-NLRF_ERR_WRONGKEY		wrong access key
 * @retval		-NLRF_ERR_NOCARD		no card detected
 * @retval		-NLRF_ERR_CARDORKEY		no card or wrong access key (For Model V1)
 */
int nlrf_writeblock(int fd, int sector, int block, const unsigned char *data,
		int length);

/**
 * @fn			int nlrf_get_modeltype(int fd);
 * @ingroup		nlrf_api
 * @brief		get model type
 *
 * @param[in]	fd			file descriptor returned by function nlrf_open
 * @retval		NLRF_MODEL_V1			Model V1(Old Model)
 * @retval		NLRF_MODEL_V2			Model V2(New Model)
 * @retval		NLRF_MODEL_UNKNOWN		No Device / Unknown Model
 */
int nlrf_get_modeltype(int fd);

#endif
