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
#include "at42qt2120.h"

#if DEF_TOUCH_DATA_STREAMER_ENABLE == 1U

#define DEF_NUM_KEYS 12u
#define OUTPUT_MODULE_CNT 2u
void uart_send_frame_header(uint8_t trans_type, uint8_t frame, uint16_t frame_len);
void uart_recv_frame_data(uint8_t frame_id, uint16_t len);

void uart_send_data(uint8_t con_or_debug, uint8_t *data_ptr, uint8_t data_len);
void copy_run_time_data(uint8_t channel_num);
void copy_general_status_data(uint8_t channel_num);

uint8_t uart_get_char(void);
void uart_get_string(uint8_t *data_recv, uint16_t len);
void UART_Write(uint8_t data);
void uart_send_data_wait(uint8_t data);

typedef struct tagAt42qt2120TuneOutputData_t
{
    uint8_t threshold;
    uint8_t aks;
    uint8_t guard;
    uint8_t pulse;
    uint8_t scale;
} at42qt2120TuneOutputData_t;

typedef struct tagCommunicationError_t
{
    uint8_t initError;
    uint8_t ConfigDataError;
    uint8_t DebugDataError;
    uint8_t StatusDataError;
} CommunicationError_t;

typedef struct __attribute__((packed))
{
    uint16_t signal_sensorData;
    uint16_t reference_sensorData;
    int16_t delta_sensorData;
    uint8_t state_sensorData;
} sensorData_t;

typedef struct tagat42qt2120TuneConfigData_t
{
    uint8_t di;
    uint8_t dth;
    uint8_t trd;
    uint8_t chargetime;
    uint8_t ttd;
    uint8_t atd;
    uint8_t lpMode;
    uint8_t sliderOptions;
} at42qt2120TuneConfigData_t;

static at42qt2120TuneOutputData_t at42qt2120TuneOutputData[DEF_NUM_KEYS];
static at42qt2120TuneConfigData_t at42qt2120TuneConfigData;

#define NO_OF_CONFIG_FRAME_ID (3U)
#define STREAMING_DEBUG_DATA (1U)
#define STREAMING_CONFIG_DATA (2U)
#define PROJECT_CONFIG_DATA_LEN (10U)

#define DEBUG_DATA_PER_CH_LEN sizeof(sensorData_t)
#define TOTAL_RUN_TIME_DATA_LEN (DEBUG_DATA_PER_CH_LEN * DEF_NUM_KEYS)

static sensorData_t runtime_data_arr;
static CommunicationError_t commError;

#define CONFIG_0_PTR ((uint8_t *)&proj_config[0])
#define CONFIG_0_LEN ((uint8_t)PROJECT_CONFIG_DATA_LEN)

#define CONFIG_1_PTR ((uint8_t *)(&at42qt2120TuneOutputData[0].threshold))
#define CONFIG_1_LEN ((uint8_t)(sizeof(at42qt2120TuneOutputData_t) * DEF_NUM_KEYS))

#define CONFIG_2_PTR ((uint8_t *)(&at42qt2120TuneConfigData.di))
#define CONFIG_2_LEN ((uint8_t)(sizeof(at42qt2120TuneConfigData_t)))

#define DATA_0_PTR ((uint8_t *)&runtime_data_arr)
#define DATA_0_ID KEY_DEBUG_DATA_ID
#define DATA_0_LEN sizeof(sensorData_t)
#define DATA_0_REPEAT DEF_NUM_KEYS
#define DATA_0_FRAME_LEN (DATA_0_LEN * DATA_0_REPEAT)

#define DATA_1_PTR ((uint8_t *)&commError.initError)
#define DATA_1_ID 0x81
#define DATA_1_LEN sizeof(CommunicationError_t)
#define DATA_1_REPEAT 1
#define DATA_1_FRAME_LEN (DATA_1_LEN * DATA_1_REPEAT)

void update_individual_config(uint8_t channel_num);
void update_common_config(uint8_t channel);
void copy_individual_config(uint8_t channel_num);
void copy_common_config(uint8_t channel);
void copy_channel_config_data(uint8_t id, uint8_t channel);

/* configuration details */
static uint8_t proj_config[PROJECT_CONFIG_DATA_LEN] = {
                                                (uint8_t)PROTOCOL_VERSION, 
                                                (uint8_t)AT42QT2120, 
                                                (uint8_t)SELF_CAP, 
                                                (uint8_t)DEF_NUM_KEYS, 
                                                ((uint8_t)SENSOR_INDIVIDUAL_CONFIG_ID | (uint8_t)SENSOR_COMMON_CONFIG_ID), 
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
static uint8_t debug_num_of_keys[OUTPUT_MODULE_CNT] = {(uint8_t)DATA_0_REPEAT, (uint8_t)DATA_1_REPEAT};
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
static volatile uint16_t command_flags = 0x0000u;
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
    commError.initError = communicationStatus.initError;
    commError.ConfigDataError = communicationStatus.ConfigDataError;
    commError.DebugDataError = communicationStatus.DebugDataError;
    commError.StatusDataError = communicationStatus.StatusDataError;
}

void update_individual_config(uint8_t channel_num)
{
    configData.key_detect_threshold[channel_num] = at42qt2120TuneOutputData[channel_num].threshold;
    configData.key_control[channel_num].bits.aks = at42qt2120TuneOutputData[channel_num].aks;
    configData.key_control[channel_num].bits.guard = at42qt2120TuneOutputData[channel_num].guard;
    configData.pulseScale[channel_num].bits.pulse = at42qt2120TuneOutputData[channel_num].pulse;
    configData.pulseScale[channel_num].bits.scale = at42qt2120TuneOutputData[channel_num].scale;
}

void update_common_config(uint8_t channel)
{

    configData.detectIntegrator = at42qt2120TuneConfigData.di;
    configData.driftHoldTime = at42qt2120TuneConfigData.dth;
    configData.touchRecalDelay = at42qt2120TuneConfigData.trd;
    configData.awayFromTouchDrift = at42qt2120TuneConfigData.atd;
    configData.charge_time = at42qt2120TuneConfigData.chargetime;
    configData.lowPowerMode = at42qt2120TuneConfigData.lpMode;
    configData.slider_options = at42qt2120TuneConfigData.sliderOptions;
    configData.towardsTouchDrift = at42qt2120TuneConfigData.ttd;
}

void copy_individual_config(uint8_t channel_num)
{
    at42qt2120TuneOutputData[channel_num].threshold = configData.key_detect_threshold[channel_num];
    at42qt2120TuneOutputData[channel_num].aks = (uint8_t)configData.key_control[channel_num].bits.aks;
    at42qt2120TuneOutputData[channel_num].guard = (uint8_t)configData.key_control[channel_num].bits.guard;
    at42qt2120TuneOutputData[channel_num].pulse = (uint8_t)configData.pulseScale[channel_num].bits.pulse;
    at42qt2120TuneOutputData[channel_num].scale = (uint8_t)configData.pulseScale[channel_num].bits.scale;
    if (channel_num == 0u)
    {
        uart_send_frame_header((uint8_t)MCU_RESPOND_CONFIG_DATA_TO_PC, uart_command_info.frame_id, (uint16_t)(sizeof(at42qt2120TuneOutputData_t) * DEF_NUM_KEYS));
        uart_send_data(STREAMING_CONFIG_DATA, (uint8_t *)&at42qt2120TuneOutputData[channel_num].threshold, (uint8_t)sizeof(at42qt2120TuneOutputData_t));
    }
    else
    {
        tx_data_ptr = (uint8_t *)&at42qt2120TuneOutputData[channel_num].threshold;
        tx_data_len = (uint8_t)sizeof(at42qt2120TuneOutputData_t);
    }
}

void copy_common_config(uint8_t channel)
{

    at42qt2120TuneConfigData.di = configData.detectIntegrator;
    at42qt2120TuneConfigData.dth = configData.driftHoldTime;
    at42qt2120TuneConfigData.trd = configData.touchRecalDelay;
    at42qt2120TuneConfigData.atd = configData.awayFromTouchDrift;
    at42qt2120TuneConfigData.chargetime = configData.charge_time;
    at42qt2120TuneConfigData.lpMode = configData.lowPowerMode;
    at42qt2120TuneConfigData.sliderOptions = configData.slider_options;
    at42qt2120TuneConfigData.ttd = configData.towardsTouchDrift;
    if (channel == 0u)
    {
        uart_send_frame_header((uint8_t)MCU_RESPOND_CONFIG_DATA_TO_PC, uart_command_info.frame_id, (uint16_t)(sizeof(at42qt2120TuneConfigData_t)));
        uart_send_data(STREAMING_CONFIG_DATA, (uint8_t *)&at42qt2120TuneConfigData.di, (uint8_t)sizeof(at42qt2120TuneConfigData_t));
    }
    else
    {
        tx_data_ptr = (uint8_t *)&at42qt2120TuneConfigData.di;
        tx_data_len = (uint8_t)sizeof(at42qt2120TuneConfigData_t);
    }
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
    uint8_t maskValue;
    uint8_t *temp_ptr = (uint8_t *)&runtime_data_arr;

    signal_temp = debugData.key_signal[channel_num];
    *temp_ptr++ = (uint8_t)(signal_temp & 0x00FFu);
    *temp_ptr++ = (uint8_t)((signal_temp & 0xFF00u) >> (uint16_t)8u);

    ref_temp = debugData.ref_data[channel_num];
    *temp_ptr++ = (uint8_t)(ref_temp & 0x00FFu);
    *temp_ptr++ = (uint8_t)((ref_temp & 0xFF00u) >> (uint16_t)8u);

    delta_temp = ((int16_t)ref_temp - (int16_t)signal_temp);
    *temp_ptr++ = (uint8_t)((uint16_t)delta_temp & 0x00FFu);
    *temp_ptr++ = (uint8_t)(((uint16_t)delta_temp & 0xFF00u) >> (uint16_t)8u);
    if (channel_num > 7u)
    {
        maskValue = (uint8_t)(statusData.key_status >> (uint16_t)8u); // keys 8-11
    }
    else
    {
        maskValue = (uint8_t)statusData.key_status; // keys 0-7
    }

    if ((maskValue & channel_num) != 0u)
    {
        *temp_ptr++ = 1u;
    }
    else
    {
        *temp_ptr++ = 0u;
    }
}

uint8_t uart_get_char(void)
{
    uint8_t data = read_buffer[read_buf_read_ptr];
    read_buf_read_ptr++;
    if (read_buf_read_ptr == UART_RX_BUF_LENGTH)
    {
        read_buf_read_ptr = 0;
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
        while (num_data > sizeof(at42qt2120TuneOutputData_t))
        {

            uint8_t *ptr = (uint8_t *)&at42qt2120TuneOutputData[ch_num].threshold;
            for (uint8_t cnt = 0u; cnt < sizeof(at42qt2120TuneOutputData_t); cnt++)
            {
                ptr[cnt] = uart_get_char();
            }

            update_individual_config(ch_num);
            ch_num++;
            num_data -= (uint16_t)sizeof(at42qt2120TuneOutputData_t);

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
            uint8_t *ptr = (uint8_t *)&at42qt2120TuneConfigData;
            for (uint8_t cnt = 0u; cnt < sizeof(at42qt2120TuneConfigData_t); cnt++)
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

/**
 * @brief UART Tx complete call back function.
 * If user callback is not NULL, call the user registered callback function
 *
 */

/**
 * @brief UART Rx complete call back function.
 * If user callback is not NULL, call the user registered callback function
 *
 */
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

void touchTuneInit(void)
{

    ${TOUCH_SERCOM_TUNE}_ReadCallbackRegister(touchUartRxComplete, touchUart);
    ${TOUCH_SERCOM_TUNE}_WriteCallbackRegister(touchUartTxComplete, touchUart);

    (void)${TOUCH_SERCOM_TUNE}_Read((void *)&rxData, 1);
}
