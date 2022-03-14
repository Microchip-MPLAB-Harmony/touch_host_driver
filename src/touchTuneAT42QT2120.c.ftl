/*******************************************************************************
  Touch Library  Release

  @Company
    Microchip Technology Inc.

  @File Name
    tuner.c

  @Summary
    QTouch Modular Library

  @Description
    Provides the two way datastreamer protocol implementation, transmission of
          module data to data visualizer software using UART port.

*******************************************************************************/

/*----------------------------------------------------------------------------
  include files
----------------------------------------------------------------------------*/
#include "touchTune.h"
#include "at42qt2120.h"

#if DEF_TOUCH_DATA_STREAMER_ENABLE == 1U

#define DEF_NUM_KEYS 12
#define OUTPUT_MODULE_CNT 2u
void uart_send_frame_header(uint8_t trans_type, uint8_t frame, uint16_t frame_len);
void uart_recv_frame_data(uint8_t frame_id, uint16_t len);

void uart_send_data(uint8_t con_or_debug, uint8_t *data_ptr, uint8_t data_len);
void copy_run_time_data(uint8_t channel_num);
void copy_general_status_data(uint8_t channel_num);

extern debugDataT debugData;
extern configurationDataT configData;
extern statusDataT statusData;
extern CommunicationStatus_t communicationStatus;
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
    uint16_t signal;
    uint16_t reference;
    int16_t delta;
    uint8_t state;
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

at42qt2120TuneOutputData_t at42qt2120TuneOutputData[DEF_NUM_KEYS];
at42qt2120TuneConfigData_t at42qt2120TuneConfigData;

#define NO_OF_CONFIG_FRAME_ID (3U)
#define STREAMING_DEBUG_DATA (1U)
#define STREAMING_CONFIG_DATA (2U)
#define PROJECT_CONFIG_DATA_LEN (10U)

#define DEBUG_DATA_PER_CH_LEN sizeof(sensorData_t)
#define TOTAL_RUN_TIME_DATA_LEN (DEBUG_DATA_PER_CH_LEN * DEF_NUM_KEYS)

sensorData_t runtime_data_arr;
CommunicationError_t commError;

#define CONFIG_0_PTR ((uint8_t *)&proj_config[0])
#define CONFIG_0_LEN ((uint8_t)PROJECT_CONFIG_DATA_LEN)

#define CONFIG_1_PTR ((uint8_t *)(&at42qt2120TuneOutputData[0].threshold))
#define CONFIG_1_LEN ((uint8_t)(sizeof(at42qt2120TuneOutputData_t) * DEF_NUM_KEYS))

#define CONFIG_2_PTR ((uint8_t *)(&at42qt2120TuneConfigData.di))
#define CONFIG_2_LEN ((uint8_t)(sizeof(at42qt2120TuneConfigData_t)))

#define DATA_0_PTR ((uint8_t *)&runtime_data_arr.signal)
#define DATA_0_ID KEY_DEBUG_DATA_ID
#define DATA_0_LEN sizeof(sensorData_t)
#define DATA_0_REPEAT DEF_NUM_KEYS
#define DATA_0_FRAME_LEN (DATA_0_LEN * DATA_0_REPEAT)

#define DATA_1_PTR ((uint8_t *)&commError.initError)
#define DATA_1_ID 0x81
#define DATA_1_LEN sizeof(CommunicationError_t)
#define DATA_1_REPEAT 1
#define DATA_1_FRAME_LEN (DATA_1_LEN * DATA_1_REPEAT)

/* configuration details */
uint8_t proj_config[PROJECT_CONFIG_DATA_LEN] = {PROTOCOL_VERSION, AT42QT2120, (SELF_CAP), (DEF_NUM_KEYS), (SENSOR_INDIVIDUAL_CONFIG_ID | SENSOR_COMMON_CONFIG_ID), (0U), (0U),
                                                (KEYS_MODULE | ERROR), (0U), (0U)}; // store the config values from DV

uint8_t frame_len_lookup[NO_OF_CONFIG_FRAME_ID] = {CONFIG_0_LEN, CONFIG_1_LEN, CONFIG_2_LEN};
uint8_t *ptr_arr[NO_OF_CONFIG_FRAME_ID] = {CONFIG_0_PTR, CONFIG_1_PTR, CONFIG_2_PTR};

/* output data details */
uint8_t *debug_frame_ptr_arr[OUTPUT_MODULE_CNT] = {DATA_0_PTR, DATA_1_PTR};
uint8_t debug_frame_id[OUTPUT_MODULE_CNT] = {DATA_0_ID, DATA_1_ID};
uint8_t debug_frame_data_len[OUTPUT_MODULE_CNT] = {DATA_0_LEN, DATA_1_LEN};
uint8_t debug_frame_total_len[OUTPUT_MODULE_CNT] = {DATA_0_FRAME_LEN, DATA_1_FRAME_LEN};
uint8_t debug_num_of_keys[OUTPUT_MODULE_CNT] = {DATA_0_REPEAT, DATA_1_REPEAT};
void (*debug_func_ptr[OUTPUT_MODULE_CNT])(uint8_t ch) = {copy_run_time_data, copy_general_status_data};

uint8_t txData = 0;

typedef struct tag_uart_command_info_t
{
    uint8_t transaction_type;
    uint8_t frame_id;
    uint16_t num_of_bytes;
    uint8_t header_status;
} uart_command_info_t;

uart_command_info_t volatile uart_command_info;

uint8_t tx_data_len = 0;
uint8_t *tx_data_ptr;

volatile uint8_t current_debug_data;
volatile uint8_t uart_tx_in_progress = 0;
volatile uint8_t uart_frame_header_flag = 1;
volatile uint8_t config_or_debug = 0;
volatile uint8_t write_buf_channel_num;
volatile uint8_t write_buf_read_ptr;
volatile uint16_t command_flags = 0x0000;
volatile uint16_t max_number_of_keys;

#if UART_RX_BUF_LENGTH <= 255
typedef uint8_t rx_buff_ptr_t;
#else
typedef uint16_t rx_buff_ptr_t;
#endif
volatile rx_buff_ptr_t read_buf_read_ptr;
volatile rx_buff_ptr_t read_buf_write_ptr;

static volatile uint8_t rxData;
uintptr_t touchUart;
void touchUartTxComplete(uintptr_t lTouchUart);
void touchUartRxComplete(uintptr_t lTouchUart);

uint8_t read_buffer[UART_RX_BUF_LENGTH];

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
    if (channel_num == 0)
    {
        uart_send_frame_header(MCU_RESPOND_CONFIG_DATA_TO_PC, uart_command_info.frame_id, (sizeof(at42qt2120TuneOutputData_t) * DEF_NUM_KEYS));
        uart_send_data(STREAMING_CONFIG_DATA, (uint8_t *)&at42qt2120TuneOutputData[channel_num].threshold, sizeof(at42qt2120TuneOutputData_t));
    }
    else
    {
        tx_data_ptr = (uint8_t *)&at42qt2120TuneOutputData[channel_num].threshold;
        tx_data_len = sizeof(at42qt2120TuneOutputData_t);
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
    if (channel == 0)
    {
        uart_send_frame_header(MCU_RESPOND_CONFIG_DATA_TO_PC, uart_command_info.frame_id, (sizeof(at42qt2120TuneConfigData_t)));
        uart_send_data(STREAMING_CONFIG_DATA, (uint8_t *)&at42qt2120TuneConfigData.di, sizeof(at42qt2120TuneConfigData_t));
    }
    else
    {
        tx_data_ptr = (uint8_t *)&at42qt2120TuneConfigData.di;
        tx_data_len = sizeof(at42qt2120TuneConfigData_t);
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
        max_number_of_keys = 1;
        uart_send_frame_header(MCU_RESPOND_CONFIG_DATA_TO_PC, uart_command_info.frame_id, frame_len_lookup[uart_command_info.frame_id]);
        uart_send_data(STREAMING_CONFIG_DATA, ptr_arr[uart_command_info.frame_id], frame_len_lookup[uart_command_info.frame_id]);
        break;
    }
}
void copy_run_time_data(uint8_t channel_num)
{

    uint16_t signal_temp, ref_temp;
    int16_t delta_temp;
    uint8_t maskValue;
    uint8_t *temp_ptr = (uint8_t *)&runtime_data_arr.signal;

    signal_temp = debugData.key_signal[channel_num];
    *temp_ptr++ = signal_temp;
    *temp_ptr++ = (signal_temp >> 8);

    ref_temp = debugData.ref_data[channel_num];
    *temp_ptr++ = ref_temp;
    *temp_ptr++ = (ref_temp >> 8);

    delta_temp = ref_temp - signal_temp;
    *temp_ptr++ = delta_temp;
    *temp_ptr++ = (delta_temp >> 8);
    if (channel_num > 7)
    {
        maskValue = statusData.key_status >> 8; // keys 8-11
    }
    else
    {
        maskValue = statusData.key_status; // keys 0-7
    }

    if (maskValue & channel_num)
    {
        *temp_ptr++ = 1;
    }
    else
    {
        *temp_ptr++ = 0;
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
    for (uint16_t idx = 0; idx < len; idx++)
    {
        *data_recv = uart_get_char();
        data_recv++;
    }
}

void touchTuneNewDataAvailable(void)
{
    command_flags |= SEND_DEBUG_DATA;
}

void UART_Write(uint8_t data)
{
    static uint8_t txData;
    txData = data;
    ${TOUCH_SERCOM_TUNE}_Write(&txData, 1);
}
void uart_send_data_wait(uint8_t data)
{
    uart_tx_in_progress = 1;
    UART_Write(data);
    while (uart_tx_in_progress == 1)
        ;
}
void uart_send_data(uint8_t con_or_debug, uint8_t *data_ptr, uint8_t data_len)
{
    if (uart_tx_in_progress == 0)
    {
        config_or_debug = con_or_debug;
        uart_tx_in_progress = 1;
        write_buf_channel_num = 1;
        write_buf_read_ptr = 1;
        tx_data_ptr = data_ptr;
        tx_data_len = data_len;
        UART_Write(tx_data_ptr[0]);
    }
}

rx_buff_ptr_t uart_min_num_bytes_received(void)
{
    int16_t retvar = (read_buf_write_ptr - read_buf_read_ptr);
    if (retvar < 0)
    {
        retvar = retvar + UART_RX_BUF_LENGTH;
    }
    return (rx_buff_ptr_t)(retvar);
}

void uart_send_frame_header(uint8_t trans_type, uint8_t frame, uint16_t frame_len)
{

    uart_frame_header_flag = 0;
    uart_send_data_wait(DV_HEADER);
    uart_send_data_wait(trans_type);
    uart_send_data_wait(frame);
    uart_send_data_wait(frame_len & 0xFF);
    uart_send_data_wait((frame_len & 0xFF00) >> 8);
    uart_frame_header_flag = 1;
}

void uart_recv_frame_data(uint8_t frame_id, uint16_t len)
{
    static uint8_t ch_num = 0;
    uint16_t num_data;
    num_data = uart_min_num_bytes_received();
    switch (frame_id)
    {
    case 1:
        while (num_data > sizeof(at42qt2120TuneOutputData_t))
        {

            uint8_t *ptr = (uint8_t *)&at42qt2120TuneOutputData[ch_num].threshold;
            for (uint8_t cnt = 0; cnt < sizeof(at42qt2120TuneOutputData_t); cnt++)
            {
                ptr[cnt] = uart_get_char();
            }

            update_individual_config(ch_num);
            ch_num++;
            num_data -= sizeof(at42qt2120TuneOutputData_t);

            if (ch_num == DEF_NUM_KEYS)
            {
                ch_num = 0;
                uart_command_info.header_status = HEADER_AWAITING;
                command_flags &= ~(1 << uart_command_info.frame_id);
                uart_get_char(); // reading footer
                break;
            }
        }
        break;

    case 2:
        while (num_data > sizeof(at42qt2120TuneConfigData_t))
        {

            uint8_t *ptr = (uint8_t *)&at42qt2120TuneConfigData.di;
            for (uint8_t cnt = 0; cnt < sizeof(at42qt2120TuneConfigData_t); cnt++)
            {
                ptr[cnt] = uart_get_char();
            }
            update_common_config(ch_num);

            num_data -= sizeof(at42qt2120TuneConfigData_t);

            ch_num = 0;
            uart_command_info.header_status = HEADER_AWAITING;
            command_flags &= ~(1 << uart_command_info.frame_id);
            uart_get_char(); // reading footer
            break;
        }
        break;

    default:
        uart_get_string(ptr_arr[uart_command_info.frame_id], uart_command_info.num_of_bytes); // frame_len_lookup[uart_command_info.frame_id]);
        uart_get_char();                                                                      // receiving footer
        break;
    }
}

void touchTuneProcess(void)
{
    static uint8_t debug_index = 0;

    switch (uart_command_info.header_status)
    {
    case HEADER_AWAITING:
        if (uart_min_num_bytes_received() > 5)
        {
            if (uart_get_char() == DV_HEADER)
            {
                uart_get_string((uint8_t *)&uart_command_info.transaction_type, 4); // uart_command_info.transaction_type ,uart_command_info.frame_id,uart_command_info.num_of_bytes
                uart_command_info.header_status = DATA_AWAITING;
            }
        }
        break;
    case DATA_AWAITING:
        if (uart_command_info.transaction_type == PC_SEND_CONFIG_DATA_TO_MCU) // user has pressed write to kit
        {
            if (uart_command_info.num_of_bytes >= UART_RX_BUF_LENGTH)
            {
                uart_recv_frame_data(uart_command_info.frame_id, uart_command_info.num_of_bytes);
            }
            else if (uart_min_num_bytes_received() > uart_command_info.num_of_bytes) // total length of bytes + footer
            {
                command_flags |= (1 << (uart_command_info.frame_id)); // (uart_command_info.frame_id - CONFIG_INFO)
                uart_command_info.header_status = DATA_RECEIVED;
            }
        }
        else if (uart_command_info.transaction_type == PC_REQUEST_CONFIG_DATA_FROM_MCU) // read from kit
        {
            if (uart_min_num_bytes_received() > 1) // Data length = 1 + footer
            {
                if ((uart_get_char() == ZERO) && (uart_get_char() == DV_FOOTER)) // requesting configuration
                {
                    command_flags |= (1 << (uart_command_info.frame_id)); // (uart_command_info.frame_id - CONFIG_INFO)
                    uart_command_info.header_status = DATA_RECEIVED;
                }
            }
        }
        break;
    case DATA_RECEIVED:
        if ((command_flags & 0x0FFF) && (uart_tx_in_progress == 0))
        {
            if (uart_command_info.transaction_type == PC_REQUEST_CONFIG_DATA_FROM_MCU) // requesting configuration
            {
                copy_channel_config_data(uart_command_info.frame_id, 0);
                uart_command_info.header_status = HEADER_AWAITING;
            }
            else if (uart_command_info.transaction_type == PC_SEND_CONFIG_DATA_TO_MCU) // PC Updating parameters.
            {
                uart_recv_frame_data(uart_command_info.frame_id, uart_command_info.num_of_bytes);
                uart_command_info.header_status = HEADER_AWAITING;
                command_flags &= ~(1 << uart_command_info.frame_id);
            }
        }
        break;
    default:
        uart_command_info.header_status = HEADER_AWAITING;
        break;
    }

    /* to send periodic data */
    if ((command_flags & SEND_DEBUG_DATA) && (uart_tx_in_progress == 0))
    {

        while (debug_func_ptr[debug_index] == NULL)
        {
            debug_index++;
            if (debug_index == OUTPUT_MODULE_CNT)
            {
                debug_index = 0;
            }
        }
        current_debug_data = debug_frame_id[debug_index];

        uart_send_frame_header(MCU_SEND_TUNE_DATA_TO_PC, current_debug_data, debug_frame_total_len[debug_index]);

        (debug_func_ptr[debug_index])(0);

        max_number_of_keys = debug_num_of_keys[debug_index];

        uart_send_data(STREAMING_DEBUG_DATA, (uint8_t *)debug_frame_ptr_arr[debug_index], debug_frame_data_len[debug_index]);

        debug_index++;

        if (debug_index == OUTPUT_MODULE_CNT)
        {
            debug_index = 0;
        }
    }
}

#endif

void touchUartTxComplete(uintptr_t touchUart)
{
#if (DEF_TOUCH_DATA_STREAMER_ENABLE == 1u)

    if (uart_frame_header_flag != 1)
    {
        uart_tx_in_progress = 0;
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
                if ((write_buf_channel_num < max_number_of_keys) && (uart_command_info.frame_id == SENSOR_INDIVIDUAL_CONFIG_ID))
                {
                    copy_channel_config_data(uart_command_info.frame_id, write_buf_channel_num);
                    write_buf_read_ptr = 1;
                    write_buf_channel_num++;
                    UART_Write(tx_data_ptr[0]);
                }
                else if ((write_buf_channel_num < max_number_of_keys) && (uart_command_info.frame_id == SENSOR_COMMON_CONFIG_ID))
                {
                    write_buf_channel_num++;
                    command_flags &= ~(1 << uart_command_info.frame_id);
                    UART_Write(DV_FOOTER);
                }
                else if (write_buf_channel_num == max_number_of_keys)
                {
                    write_buf_channel_num++;
                    command_flags &= ~(1 << uart_command_info.frame_id);
                    UART_Write(DV_FOOTER);
                }
                else
                {
                    uart_tx_in_progress = 0;
                }
            }
            else if (config_or_debug == STREAMING_DEBUG_DATA)
            {
                /* per channel data are sent channel by channel to reduce RAM requirements */
                if (write_buf_channel_num < max_number_of_keys)
                {
                    (*debug_func_ptr[current_debug_data & 0x0F])(write_buf_channel_num);
                    write_buf_read_ptr = 1;
                    write_buf_channel_num++;
                    UART_Write(tx_data_ptr[0]);
                }
                else if (write_buf_channel_num == max_number_of_keys)
                {
                    write_buf_channel_num++;
                    command_flags &= ~(SEND_DEBUG_DATA); // clearing off debug data
                    UART_Write(DV_FOOTER);
                }
                else
                {
                    uart_tx_in_progress = 0;
                }
            }
        }
    }
#endif
}

static volatile uint8_t rxData;

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
void touchUartRxComplete(uintptr_t touchUart)
{

    read_buffer[read_buf_write_ptr] = rxData;
    read_buf_write_ptr++;
    if (read_buf_write_ptr == UART_RX_BUF_LENGTH)
    {
        read_buf_write_ptr = 0;
    }

    ${TOUCH_SERCOM_TUNE}_Read((void *)&rxData, 1);
}

void touchTuneInit(void)
{

    ${TOUCH_SERCOM_TUNE}_ReadCallbackRegister(touchUartRxComplete, touchUart);
    ${TOUCH_SERCOM_TUNE}_WriteCallbackRegister(touchUartTxComplete, touchUart);

    ${TOUCH_SERCOM_TUNE}_Read((void *)&rxData, 1);
}
