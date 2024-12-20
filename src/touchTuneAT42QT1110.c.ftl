/*******************************************************************************
  MPLAB Harmony Touch Host Interface ${REL_VER} Release

  @Company
    Microchip Technology Inc.

  @File Name
    TouchTune.c

  @Summary
    QTouch Modular Library

  @Description
    Provides the two way datastreamer protocol implementation, transmission of
          module data to data visualizer software using UART port.

*******************************************************************************/
// DOM-IGNORE-BEGIN
/*******************************************************************************
 * Copyright (C) ${REL_YEAR} Microchip Technology Inc. and its subsidiaries.
 *
 * Subject to your compliance with these terms, you may use Microchip software
 * and any derivatives exclusively with Microchip products. It is your
 * responsibility to comply with third party license terms applicable to your
 * use of third party software (including open source software) that may
 * accompany Microchip software.
 *
 * THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
 * EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
 * WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
 * PARTICULAR PURPOSE.
 *
 * IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
 * INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
 * WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
 * BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
 * FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
 * ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
 * THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
 *******************************************************************************/
// DOM-IGNORE-END


/*----------------------------------------------------------------------------
  include files
----------------------------------------------------------------------------*/
#include "touchTune.h"
#include "at42qt1110.h"

#if DEF_TOUCH_DATA_STREAMER_ENABLE == 1U

#define DEF_NUM_KEYS 11u

void uart_send_frame_header(uint8_t trans_type, uint8_t frame, uint16_t frame_len);
void uart_recv_frame_data(uint8_t frame_id, uint16_t len);

void uart_send_data(uint8_t con_or_debug, uint8_t *data_ptr, uint8_t data_len);
void copy_run_time_data(uint8_t channel_num);
void copy_general_status_data(uint8_t channel_num);

uint8_t uart_get_char(void);
void uart_get_string(uint8_t *data_recv, uint16_t len);
void UART_Write(uint8_t data);
void uart_send_data_wait(uint8_t data);
typedef struct tagAt42qt1110TuneOutputData_t
{
    uint8_t threshold;
    uint8_t hysteresis;
    uint8_t recal;
    uint8_t drift;
    uint8_t aks;
} at42qt1110TuneOutputData_t;

typedef struct tagCommunicationError_t
{
    uint8_t error;
    uint8_t initError;
    uint8_t crcError;
    uint8_t errorCommand;
    uint8_t readStatus;
    uint8_t writeStatus;
} CommunicationError_t;

typedef struct __attribute__((packed))
{
    uint16_t signal_sensorData;
    uint16_t reference_sensorData;
    int16_t delta_sensorData;
    uint8_t state_sensorData;
} sensorData_t;

typedef struct tagat42qt1110TuneConfigData_t
{
    uint8_t di;
    uint8_t dth;
    uint8_t ptr;
    uint8_t physt;
    uint8_t pdrift;
    uint8_t precal;
    uint8_t burstlimit;
} at42qt1110TuneConfigData_t;

#define OUTPUT_MODULE_CNT (2U)
#define NO_OF_CONFIG_FRAME_ID (3U)
#define STREAMING_DEBUG_DATA (1U)
#define STREAMING_CONFIG_DATA (2U)
#define PROJECT_CONFIG_DATA_LEN (10U)

#define DEBUG_DATA_PER_CH_LEN sizeof(sensorData_t)
#define TOTAL_RUN_TIME_DATA_LEN (DEBUG_DATA_PER_CH_LEN * DEF_NUM_KEYS)

static at42qt1110TuneOutputData_t at42qt1110TuneOutputData[DEF_NUM_KEYS];
static at42qt1110TuneConfigData_t at42qt1110TuneConfigData;
static sensorData_t runtime_data_arr;
static CommunicationError_t commError;

#define CONFIG_0_PTR ((uint8_t *)&proj_config[0])
#define CONFIG_0_LEN ((uint8_t)PROJECT_CONFIG_DATA_LEN)

#define CONFIG_1_PTR ((uint8_t *)(&at42qt1110TuneOutputData[0].threshold))
#define CONFIG_1_LEN ((uint8_t)(sizeof(at42qt1110TuneOutputData_t) * DEF_NUM_KEYS))

#define CONFIG_2_PTR ((uint8_t *)(&at42qt1110TuneConfigData.di))
#define CONFIG_2_LEN ((uint8_t)(sizeof(at42qt1110TuneConfigData_t)))

#define DATA_0_PTR ((uint8_t *)&runtime_data_arr)
#define DATA_0_ID KEY_DEBUG_DATA_ID
#define DATA_0_LEN sizeof(sensorData_t)
#define DATA_0_REPEAT DEF_NUM_KEYS
#define DATA_0_FRAME_LEN (DATA_0_LEN * DATA_0_REPEAT)

#define DATA_1_PTR ((uint8_t *)&commError.error)
#define DATA_1_ID 0x81u
#define DATA_1_LEN sizeof(CommunicationError_t)
#define DATA_1_REPEAT 1u
#define DATA_1_FRAME_LEN (DATA_1_LEN * DATA_1_REPEAT)

void update_individual_config(uint8_t channel);
void update_common_config(uint8_t channel);
void copy_individual_config(uint8_t channel);
void copy_common_config(uint8_t channel);
void copy_channel_config_data(uint8_t id, uint8_t channel);
/* configuration details */
static uint8_t proj_config[PROJECT_CONFIG_DATA_LEN] = {
                                                (uint8_t)PROTOCOL_VERSION, 
                                                (uint8_t)AT42QT1110, 
                                                (uint8_t)(SELF_CAP), 
                                                (uint8_t)(DEF_NUM_KEYS), 
                                                ((uint8_t)SENSOR_COMMON_CONFIG_ID | (uint8_t)SENSOR_INDIVIDUAL_CONFIG_ID), 
                                                (0U), 
                                                (0U),
                                                ((uint8_t)KEYS_MODULE | (uint8_t)ERROR), 
                                                (0U), 
                                                (0U)
                                                }; // store the config values from DV

static uint8_t frame_len_lookup[NO_OF_CONFIG_FRAME_ID] = {CONFIG_0_LEN, CONFIG_1_LEN, CONFIG_2_LEN};
static uint8_t *ptr_arr[NO_OF_CONFIG_FRAME_ID] = {CONFIG_0_PTR, CONFIG_1_PTR, CONFIG_2_PTR};

/* output data details */
static uint8_t *debug_frame_ptr_arr[OUTPUT_MODULE_CNT] = {DATA_0_PTR, DATA_1_PTR};
static uint8_t debug_frame_id[OUTPUT_MODULE_CNT] = {(uint8_t)DATA_0_ID, DATA_1_ID};
static uint8_t debug_frame_data_len[OUTPUT_MODULE_CNT] = {(uint8_t)DATA_0_LEN, (uint8_t)DATA_1_LEN};
static uint8_t debug_frame_total_len[OUTPUT_MODULE_CNT] = {DATA_0_FRAME_LEN, DATA_1_FRAME_LEN};
static uint8_t debug_num_of_keys[OUTPUT_MODULE_CNT] = {DATA_0_REPEAT, DATA_1_REPEAT};
static void (*debug_func_ptr[OUTPUT_MODULE_CNT])(uint8_t ch) = {copy_run_time_data, copy_general_status_data};

typedef struct tag_uart_command_info_t
{
    uint8_t transaction_type;
    uint8_t frame_id;
    uint16_t num_of_bytes;
    uint8_t header_status;
} uart_command_info_t;

static uart_command_info_t uart_command_info;

static uint8_t tx_data_len = 0u;
static uint8_t *tx_data_ptr;

static volatile uint8_t current_debug_data;
static volatile uint8_t uart_tx_in_progress = 0u;
static volatile uint8_t uart_frame_header_flag = 1u;
static volatile uint8_t config_or_debug = 0u;
static uint8_t write_buf_channel_num;
static volatile uint8_t write_buf_read_ptr;
volatile uint16_t command_flags = 0x0000u;
static uint16_t max_number_of_keys;

#if UART_RX_BUF_LENGTH <= 255u
typedef uint8_t rx_buff_ptr_t;
#else
typedef uint16_t rx_buff_ptr_t;
#endif
static volatile rx_buff_ptr_t read_buf_read_ptr = 0u;
static volatile rx_buff_ptr_t read_buf_write_ptr = 0u;

rx_buff_ptr_t uart_min_num_bytes_received(void);

static uint8_t rxData;
static uintptr_t touchUart;

static uint8_t read_buffer[UART_RX_BUF_LENGTH];

void copy_general_status_data(uint8_t channel_num)
{
    commError.error = communicationStatus.error;
    commError.initError = communicationStatus.initError;
    commError.crcError = communicationStatus.crcError;
    commError.errorCommand = communicationStatus.errorCommand;
    commError.readStatus = communicationStatus.readStatus;
    commError.writeStatus = communicationStatus.writeStatus;
}

void copy_individual_config(uint8_t channel)
{
    at42qt1110TuneOutputData[0].threshold = setup_block.KEY_0_NTHR;
    at42qt1110TuneOutputData[1].threshold = setup_block.KEY_1_NTHR;
    at42qt1110TuneOutputData[2].threshold = setup_block.KEY_2_NTHR;
    at42qt1110TuneOutputData[3].threshold = setup_block.KEY_3_NTHR;
    at42qt1110TuneOutputData[4].threshold = setup_block.KEY_4_NTHR;
    at42qt1110TuneOutputData[5].threshold = setup_block.KEY_5_NTHR;
    at42qt1110TuneOutputData[6].threshold = setup_block.KEY_6_NTHR;
    at42qt1110TuneOutputData[7].threshold = setup_block.KEY_7_NTHR;
    at42qt1110TuneOutputData[8].threshold = setup_block.KEY_8_NTHR;
    at42qt1110TuneOutputData[9].threshold = setup_block.KEY_9_NTHR;
    at42qt1110TuneOutputData[10].threshold = setup_block.KEY_10_NTHR;
    at42qt1110TuneOutputData[0].hysteresis = setup_block.KEY_0_NHYST;
    at42qt1110TuneOutputData[1].hysteresis = setup_block.KEY_1_NHYST;
    at42qt1110TuneOutputData[2].hysteresis = setup_block.KEY_2_NHYST;
    at42qt1110TuneOutputData[3].hysteresis = setup_block.KEY_3_NHYST;
    at42qt1110TuneOutputData[4].hysteresis = setup_block.KEY_4_NHYST;
    at42qt1110TuneOutputData[5].hysteresis = setup_block.KEY_5_NHYST;
    at42qt1110TuneOutputData[6].hysteresis = setup_block.KEY_6_NHYST;
    at42qt1110TuneOutputData[7].hysteresis = setup_block.KEY_7_NHYST;
    at42qt1110TuneOutputData[8].hysteresis = setup_block.KEY_8_NHYST;
    at42qt1110TuneOutputData[9].hysteresis = setup_block.KEY_9_NHYST;
    at42qt1110TuneOutputData[10].hysteresis = setup_block.KEY_10_NHYST;
    at42qt1110TuneOutputData[0].drift = setup_block.KEY_0_NDRIFT;
    at42qt1110TuneOutputData[1].drift = setup_block.KEY_1_NDRIFT;
    at42qt1110TuneOutputData[2].drift = setup_block.KEY_2_NDRIFT;
    at42qt1110TuneOutputData[3].drift = setup_block.KEY_3_NDRIFT;
    at42qt1110TuneOutputData[4].drift = setup_block.KEY_4_NDRIFT;
    at42qt1110TuneOutputData[5].drift = setup_block.KEY_5_NDRIFT;
    at42qt1110TuneOutputData[6].drift = setup_block.KEY_6_NDRIFT;
    at42qt1110TuneOutputData[7].drift = setup_block.KEY_7_NDRIFT;
    at42qt1110TuneOutputData[8].drift = setup_block.KEY_8_NDRIFT;
    at42qt1110TuneOutputData[9].drift = setup_block.KEY_9_NDRIFT;
    at42qt1110TuneOutputData[10].drift = setup_block.KEY_10_NDRIFT;
    at42qt1110TuneOutputData[0].recal = setup_block.KEY_0_NRD;
    at42qt1110TuneOutputData[1].recal = setup_block.KEY_1_NRD;
    at42qt1110TuneOutputData[2].recal = setup_block.KEY_2_NRD;
    at42qt1110TuneOutputData[3].recal = setup_block.KEY_3_NRD;
    at42qt1110TuneOutputData[4].recal = setup_block.KEY_4_NRD;
    at42qt1110TuneOutputData[5].recal = setup_block.KEY_5_NRD;
    at42qt1110TuneOutputData[6].recal = setup_block.KEY_6_NRD;
    at42qt1110TuneOutputData[7].recal = setup_block.KEY_7_NRD;
    at42qt1110TuneOutputData[8].recal = setup_block.KEY_8_NRD;
    at42qt1110TuneOutputData[9].recal = setup_block.KEY_9_NRD;
    at42qt1110TuneOutputData[10].recal = setup_block.KEY_10_NRD;
    at42qt1110TuneOutputData[0].aks = setup_block.AKS_0;
    at42qt1110TuneOutputData[1].aks = setup_block.AKS_1;
    at42qt1110TuneOutputData[2].aks = setup_block.AKS_2;
    at42qt1110TuneOutputData[3].aks = setup_block.AKS_3;
    at42qt1110TuneOutputData[4].aks = setup_block.AKS_4;
    at42qt1110TuneOutputData[5].aks = setup_block.AKS_5;
    at42qt1110TuneOutputData[6].aks = setup_block.AKS_6;
    at42qt1110TuneOutputData[7].aks = setup_block.AKS_7;
    at42qt1110TuneOutputData[8].aks = setup_block.AKS_8;
    at42qt1110TuneOutputData[9].aks = setup_block.AKS_9;
    at42qt1110TuneOutputData[10].aks = setup_block.AKS_10;

    if (channel == 0u)
    {
        uart_send_frame_header((uint8_t)MCU_RESPOND_CONFIG_DATA_TO_PC, uart_command_info.frame_id, (uint16_t)(sizeof(at42qt1110TuneOutputData_t) * DEF_NUM_KEYS));
        uart_send_data(STREAMING_CONFIG_DATA, (uint8_t *)&at42qt1110TuneOutputData[channel].threshold, (uint8_t)sizeof(at42qt1110TuneOutputData_t));
    }
    else
    {
        tx_data_ptr = (uint8_t *)&at42qt1110TuneOutputData[channel].threshold;
        tx_data_len = (uint8_t)sizeof(at42qt1110TuneOutputData_t);
    }
}

void copy_common_config(uint8_t channel)
{

    at42qt1110TuneConfigData.di = setup_block.DIL;
    at42qt1110TuneConfigData.dth = setup_block.DHT;
    at42qt1110TuneConfigData.pdrift = setup_block.PDRIFT;
    at42qt1110TuneConfigData.physt = setup_block.PHYST;
    at42qt1110TuneConfigData.precal = setup_block.PRD;
    at42qt1110TuneConfigData.ptr = setup_block.PTHR;
    at42qt1110TuneConfigData.burstlimit = setup_block.LBL;
    if (channel == 0u)
    {
        uart_send_frame_header((uint8_t)MCU_RESPOND_CONFIG_DATA_TO_PC, uart_command_info.frame_id, (uint16_t)(sizeof(at42qt1110TuneConfigData_t)));
        uart_send_data(STREAMING_CONFIG_DATA, (uint8_t *)&at42qt1110TuneConfigData.di, (uint8_t)sizeof(at42qt1110TuneConfigData_t));
    }
    else
    {
        tx_data_ptr = (uint8_t *)&at42qt1110TuneConfigData.di;
        tx_data_len = (uint8_t)sizeof(at42qt1110TuneConfigData_t);
    }
}

void update_individual_config(uint8_t channel)
{
    setup_block.KEY_0_NTHR = at42qt1110TuneOutputData[0].threshold;
    setup_block.KEY_1_NTHR = at42qt1110TuneOutputData[1].threshold;
    setup_block.KEY_2_NTHR = at42qt1110TuneOutputData[2].threshold;
    setup_block.KEY_3_NTHR = at42qt1110TuneOutputData[3].threshold;
    setup_block.KEY_4_NTHR = at42qt1110TuneOutputData[4].threshold;
    setup_block.KEY_5_NTHR = at42qt1110TuneOutputData[5].threshold;
    setup_block.KEY_6_NTHR = at42qt1110TuneOutputData[6].threshold;
    setup_block.KEY_7_NTHR = at42qt1110TuneOutputData[7].threshold;
    setup_block.KEY_8_NTHR = at42qt1110TuneOutputData[8].threshold;
    setup_block.KEY_9_NTHR = at42qt1110TuneOutputData[9].threshold;
    setup_block.KEY_10_NTHR = at42qt1110TuneOutputData[10].threshold;
    setup_block.KEY_0_NHYST = at42qt1110TuneOutputData[0].hysteresis;
    setup_block.KEY_1_NHYST = at42qt1110TuneOutputData[1].hysteresis;
    setup_block.KEY_2_NHYST = at42qt1110TuneOutputData[2].hysteresis;
    setup_block.KEY_3_NHYST = at42qt1110TuneOutputData[3].hysteresis;
    setup_block.KEY_4_NHYST = at42qt1110TuneOutputData[4].hysteresis;
    setup_block.KEY_5_NHYST = at42qt1110TuneOutputData[5].hysteresis;
    setup_block.KEY_6_NHYST = at42qt1110TuneOutputData[6].hysteresis;
    setup_block.KEY_7_NHYST = at42qt1110TuneOutputData[7].hysteresis;
    setup_block.KEY_8_NHYST = at42qt1110TuneOutputData[8].hysteresis;
    setup_block.KEY_9_NHYST = at42qt1110TuneOutputData[9].hysteresis;
    setup_block.KEY_10_NHYST = at42qt1110TuneOutputData[10].hysteresis;
    setup_block.KEY_0_NDRIFT = at42qt1110TuneOutputData[0].drift;
    setup_block.KEY_1_NDRIFT = at42qt1110TuneOutputData[1].drift;
    setup_block.KEY_2_NDRIFT = at42qt1110TuneOutputData[2].drift;
    setup_block.KEY_3_NDRIFT = at42qt1110TuneOutputData[3].drift;
    setup_block.KEY_4_NDRIFT = at42qt1110TuneOutputData[4].drift;
    setup_block.KEY_5_NDRIFT = at42qt1110TuneOutputData[5].drift;
    setup_block.KEY_6_NDRIFT = at42qt1110TuneOutputData[6].drift;
    setup_block.KEY_7_NDRIFT = at42qt1110TuneOutputData[7].drift;
    setup_block.KEY_8_NDRIFT = at42qt1110TuneOutputData[8].drift;
    setup_block.KEY_9_NDRIFT = at42qt1110TuneOutputData[9].drift;
    setup_block.KEY_10_NDRIFT = at42qt1110TuneOutputData[10].drift;
    setup_block.KEY_0_NRD = at42qt1110TuneOutputData[0].recal;
    setup_block.KEY_1_NRD = at42qt1110TuneOutputData[1].recal;
    setup_block.KEY_2_NRD = at42qt1110TuneOutputData[2].recal;
    setup_block.KEY_3_NRD = at42qt1110TuneOutputData[3].recal;
    setup_block.KEY_4_NRD = at42qt1110TuneOutputData[4].recal;
    setup_block.KEY_5_NRD = at42qt1110TuneOutputData[5].recal;
    setup_block.KEY_6_NRD = at42qt1110TuneOutputData[6].recal;
    setup_block.KEY_7_NRD = at42qt1110TuneOutputData[7].recal;
    setup_block.KEY_8_NRD = at42qt1110TuneOutputData[8].recal;
    setup_block.KEY_9_NRD = at42qt1110TuneOutputData[9].recal;
    setup_block.KEY_10_NRD = at42qt1110TuneOutputData[10].recal;
    setup_block.AKS_0 = at42qt1110TuneOutputData[0].aks;
    setup_block.AKS_1 = at42qt1110TuneOutputData[1].aks;
    setup_block.AKS_2 = at42qt1110TuneOutputData[2].aks;
    setup_block.AKS_3 = at42qt1110TuneOutputData[3].aks;
    setup_block.AKS_4 = at42qt1110TuneOutputData[4].aks;
    setup_block.AKS_5 = at42qt1110TuneOutputData[5].aks;
    setup_block.AKS_6 = at42qt1110TuneOutputData[6].aks;
    setup_block.AKS_7 = at42qt1110TuneOutputData[7].aks;
    setup_block.AKS_8 = at42qt1110TuneOutputData[8].aks;
    setup_block.AKS_9 = at42qt1110TuneOutputData[9].aks;
    setup_block.AKS_10 = at42qt1110TuneOutputData[10].aks;
}

void update_common_config(uint8_t channel)
{
    setup_block.DIL = at42qt1110TuneConfigData.di;
    setup_block.DHT = at42qt1110TuneConfigData.dth;
    setup_block.PDRIFT = at42qt1110TuneConfigData.pdrift;
    setup_block.PHYST = at42qt1110TuneConfigData.physt;
    setup_block.PRD = at42qt1110TuneConfigData.precal;
    setup_block.PTHR = at42qt1110TuneConfigData.ptr;
    setup_block.LBL = at42qt1110TuneConfigData.burstlimit;
}

void copy_channel_config_data(uint8_t id, uint8_t channel)
{
    switch (id)
    {
    case 1:
        copy_individual_config(channel);
        break;
    case 2:
        copy_common_config(channel);
        break;
    default:
        max_number_of_keys = 1u;
        uart_send_frame_header((uint8_t)MCU_RESPOND_CONFIG_DATA_TO_PC, uart_command_info.frame_id, frame_len_lookup[uart_command_info.frame_id]);
        uart_send_data(STREAMING_CONFIG_DATA, ptr_arr[uart_command_info.frame_id], frame_len_lookup[uart_command_info.frame_id]);
        break;
    }
}

void copy_run_time_data(uint8_t channel_num)
{
    uint16_t signal_temp, ref_temp;
    int16_t delta_temp;
    uint8_t *temp_ptr = (uint8_t *)&runtime_data_arr;

    signal_temp = at42qt1110DebugData[channel_num].signal_at42qt;
    *temp_ptr++ = (uint8_t)signal_temp;
    *temp_ptr++ = (uint8_t)(signal_temp >> (uint16_t)8u);

    ref_temp = at42qt1110DebugData[channel_num].reference_at42qt;
    *temp_ptr++ = (uint8_t)ref_temp;
    *temp_ptr++ = (uint8_t)(ref_temp >> (uint16_t)8u);

    delta_temp = ((int16_t)signal_temp - (int16_t)ref_temp);
    *temp_ptr++ = (uint8_t)delta_temp;
    *temp_ptr++ = (uint8_t)((uint16_t)delta_temp >> (int16_t)8u);

    *temp_ptr++ = at42qt1110DebugData[channel_num].status_at42qt;
}
uint8_t uart_get_char(void)
{
    uint8_t data = read_buffer[read_buf_read_ptr];
    read_buf_read_ptr++;
    if (read_buf_read_ptr == UART_RX_BUF_LENGTH)
    {
        read_buf_read_ptr = 0u;
    }
    return data;
}

void uart_get_string(uint8_t *data_recv, uint16_t len)
{
    for (uint16_t idx = 0u; idx < len; idx++)
    {
        *data_recv = uart_get_char();
        data_recv++;
    }
}

void touchTuneNewDataAvailable(void)
{
    command_flags |= (uint16_t)SEND_DEBUG_DATA;
}

void UART_Write(uint8_t data)
{
    static uint8_t txData;
    txData = data;
    (void)${TOUCH_SERCOM_TUNE}_Write(&txData, 1);
}

void uart_send_data_wait(uint8_t data)
{
    uart_tx_in_progress = 1u;
    UART_Write(data);
    do
    {
        // wait until transmission completes
    }while (uart_tx_in_progress == 1u);
}

void uart_send_data(uint8_t con_or_debug, uint8_t *data_ptr, uint8_t data_len)
{
    if (uart_tx_in_progress == 0u)
    {
        config_or_debug = con_or_debug;
        uart_tx_in_progress = 1u;
        write_buf_channel_num = 1u;
        write_buf_read_ptr = 1u;
        tx_data_ptr = data_ptr;
        tx_data_len = data_len;
        UART_Write(tx_data_ptr[0]);
    }
}

rx_buff_ptr_t uart_min_num_bytes_received(void)
{
    int16_t retvar = (int16_t) read_buf_write_ptr;
	retvar -= (int16_t) read_buf_read_ptr;
	if (retvar < 0)
    {
		retvar = retvar + (int16_t) UART_RX_BUF_LENGTH;
    }
    return (rx_buff_ptr_t)(retvar);
}

void uart_send_frame_header(uint8_t trans_type, uint8_t frame, uint16_t frame_len)
{
    uart_frame_header_flag = 0u;
    uart_send_data_wait(DV_HEADER);
    uart_send_data_wait(trans_type);
    uart_send_data_wait(frame);
    uart_send_data_wait((uint8_t)(frame_len & 0x00FFu));
    uart_send_data_wait((uint8_t)((frame_len & 0xFF00u) >> 8u));
    uart_frame_header_flag = 1u; 
}

void uart_recv_frame_data(uint8_t frame_id, uint16_t len)
{
    static uint8_t ch_num = 0u;
    uint16_t num_data = 0u;
    num_data = uart_min_num_bytes_received();
    switch (frame_id)
    {
    case 1:
        while (num_data > sizeof(at42qt1110TuneOutputData_t))
        {

            uint8_t *ptr = (uint8_t *)&at42qt1110TuneOutputData[ch_num].threshold;
            for (uint8_t cnt = 0u; cnt < sizeof(at42qt1110TuneOutputData_t); cnt++)
            {
                ptr[cnt] = uart_get_char();
            }

            update_individual_config(ch_num);
            ch_num++;
            num_data -= (uint16_t)sizeof(at42qt1110TuneOutputData_t);

            if (ch_num == DEF_NUM_KEYS)
            {
                ch_num = 0u;
                uart_command_info.header_status = HEADER_AWAITING;
                command_flags &= ~((uint16_t)1u << uart_command_info.frame_id);
                (void)uart_get_char(); // reading footer
                break;
            }
        }
        break;

    case 2:
        {
            uint8_t *ptr = (uint8_t *)&at42qt1110TuneConfigData;
            for (uint8_t cnt = 0u; cnt < sizeof(at42qt1110TuneConfigData_t); cnt++)
            {
                ptr[cnt] = uart_get_char();
            }
            update_common_config(ch_num);

            ch_num = 0u;
            uart_command_info.header_status = HEADER_AWAITING;
            command_flags &= ~((uint16_t)1u << uart_command_info.frame_id);
            (void)uart_get_char(); // reading footer
        }
        break;

    default:
        uart_get_string(ptr_arr[uart_command_info.frame_id], uart_command_info.num_of_bytes); // frame_len_lookup[uart_command_info.frame_id]);
        (void)uart_get_char();                                                                      // receiving footer
        break;
    }
}

void touchTuneInit(void)
{

    ${TOUCH_SERCOM_TUNE}_WriteCallbackRegister(touchUartTxComplete, touchUart);
    ${TOUCH_SERCOM_TUNE}_ReadCallbackRegister(touchUartRxComplete, touchUart);

    (void)${TOUCH_SERCOM_TUNE}_Read((void *)&rxData, 1);
}

void touchTuneProcess(void)
{
    static uint8_t debug_index = 0u;

    switch (uart_command_info.header_status)
    {
    case HEADER_AWAITING:
        if (uart_min_num_bytes_received() > 5u)
        {
            if (uart_get_char() == DV_HEADER)
            {
                uart_get_string((uint8_t *)&uart_command_info, 4); // uart_command_info.transaction_type ,uart_command_info.frame_id,uart_command_info.num_of_bytes
                uart_command_info.header_status = DATA_AWAITING;
            }
        }
        break;
    case DATA_AWAITING:
        if (uart_command_info.transaction_type == (uint8_t)PC_SEND_CONFIG_DATA_TO_MCU) // user has pressed write to kit
        {
            if (uart_command_info.num_of_bytes >= UART_RX_BUF_LENGTH)
            {
                uart_recv_frame_data(uart_command_info.frame_id, uart_command_info.num_of_bytes);
            }
            else if (uart_min_num_bytes_received() > uart_command_info.num_of_bytes) // total length of bytes + footer
            {
                command_flags |= ((uint16_t)1u << (uart_command_info.frame_id)); // (uart_command_info.frame_id - CONFIG_INFO)
                uart_command_info.header_status = DATA_RECEIVED;
            }
            else
            {
                    // do nothing...
            }
        }
        else if (uart_command_info.transaction_type == (uint8_t)PC_REQUEST_CONFIG_DATA_FROM_MCU) // read from kit
        {
            if (uart_min_num_bytes_received() > 1u) // Data length = 1 + footer
            {
                uint8_t data1 = uart_get_char();
                uint8_t data2 = uart_get_char();
                if((data1 == ZERO) && (data2 == DV_FOOTER))     // requesting configuration
                {
                    command_flags |= ((uint16_t)1u << (uart_command_info.frame_id)); // (uart_command_info.frame_id - CONFIG_INFO)
                    uart_command_info.header_status = DATA_RECEIVED;
                }
            }
        }
        else
        {
            // do nothing...
        }
        break;
    case DATA_RECEIVED:
        if(uart_tx_in_progress == 0u)
        {
            if ((command_flags & 0x0FFFu) != 0u)
            {
                if (uart_command_info.transaction_type == (uint8_t)PC_REQUEST_CONFIG_DATA_FROM_MCU) // requesting configuration
                {
                    copy_channel_config_data(uart_command_info.frame_id, 0u);
                    uart_command_info.header_status = HEADER_AWAITING;
                }
                else if (uart_command_info.transaction_type == (uint8_t)PC_SEND_CONFIG_DATA_TO_MCU) // PC Updating parameters.
                {
                    uart_recv_frame_data(uart_command_info.frame_id, uart_command_info.num_of_bytes);
                    uart_command_info.header_status = HEADER_AWAITING;
                    command_flags &= ~((uint16_t)1u << uart_command_info.frame_id);
                }
                else
                {
                    // do nothing...
                }
            }
        }
        break;
    default:
        uart_command_info.header_status = HEADER_AWAITING;
        break;
    }
    
    if(uart_tx_in_progress == 0u)
    {
        /* to send periodic data */
        if ((command_flags & SEND_DEBUG_DATA) == SEND_DEBUG_DATA)
        {
            while (debug_func_ptr[debug_index] == NULL)
            {
                debug_index++;
                if (debug_index == OUTPUT_MODULE_CNT)
                {
                    debug_index = 0u;
                }
            }
            current_debug_data = debug_frame_id[debug_index];

            uart_send_frame_header((uint8_t)MCU_SEND_TUNE_DATA_TO_PC, current_debug_data, debug_frame_total_len[debug_index]);

            (debug_func_ptr[debug_index])(0u);

            max_number_of_keys = debug_num_of_keys[debug_index];

            uart_send_data(STREAMING_DEBUG_DATA, (uint8_t *)debug_frame_ptr_arr[debug_index], debug_frame_data_len[debug_index]);

            debug_index++;

            if (debug_index == OUTPUT_MODULE_CNT)
            {
                debug_index = 0u;
            }
        }
    }
}

#endif

void touchUartTxComplete(uintptr_t lTouchUart)
{
    (void)lTouchUart; // added for MISRA compliance.
#if (DEF_TOUCH_DATA_STREAMER_ENABLE == 1u)

    if (uart_frame_header_flag != 1u)
    {
        uart_tx_in_progress = 0u;
    }
    else
    {
        if (write_buf_read_ptr < tx_data_len)
        {
            UART_Write(tx_data_ptr[write_buf_read_ptr]);
            write_buf_read_ptr++;
        }
        else
        {
            if (config_or_debug == STREAMING_CONFIG_DATA)
            {
                /* per channel data are sent channel by channel to reduce RAM requirements */
                if ((write_buf_channel_num < max_number_of_keys) && (uart_command_info.frame_id == (uint8_t)SENSOR_INDIVIDUAL_CONFIG_ID))
                {
                    copy_channel_config_data(uart_command_info.frame_id, write_buf_channel_num);
                    write_buf_read_ptr = 1u;
                    write_buf_channel_num++;
                    UART_Write(tx_data_ptr[0u]);
                }
                else if ((write_buf_channel_num < max_number_of_keys) && (uart_command_info.frame_id == (uint8_t)SENSOR_COMMON_CONFIG_ID))
                {
                    write_buf_channel_num++;
                    command_flags &= ~((uint16_t)1u << uart_command_info.frame_id);
                    UART_Write(DV_FOOTER);
                }
                else if (write_buf_channel_num == max_number_of_keys)
                {
                    write_buf_channel_num++;
                    command_flags &= ~((uint16_t)1u << uart_command_info.frame_id);
                    UART_Write(DV_FOOTER);
                }
                else
                {
                    uart_tx_in_progress = 0u;
                }
            }
            else if (config_or_debug == STREAMING_DEBUG_DATA)
            {
                /* per channel data are sent channel by channel to reduce RAM requirements */
                if (write_buf_channel_num < max_number_of_keys)
                {
                    (*debug_func_ptr[current_debug_data & 0x0Fu])(write_buf_channel_num);
                    write_buf_read_ptr = 1u;
                    write_buf_channel_num++;
                    UART_Write(tx_data_ptr[0u]);   
                }
                else if (write_buf_channel_num == max_number_of_keys)
                {
                    write_buf_channel_num++;
                    command_flags &= (uint16_t)~(SEND_DEBUG_DATA); // clearing off debug data
                    UART_Write(DV_FOOTER);
                }
                else
                {
                    uart_tx_in_progress = 0u;
                }
            }
            else
            {
                // do nothing...
            }
        }
    }
#endif
}


void touchUartRxComplete(uintptr_t lTouchUart)
{
    (void)lTouchUart;
    read_buffer[read_buf_write_ptr] = rxData;
    read_buf_write_ptr++;
    if (read_buf_write_ptr == UART_RX_BUF_LENGTH)
    {
        read_buf_write_ptr = 0u;
    }
     (void)${TOUCH_SERCOM_TUNE}_Read((void *)&rxData, 1);
}
