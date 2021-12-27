#ifndef OSCILLOSCPOE_REPEATER_H
#define OSCILLOSCPOE_REPEATER_H

enum { AM_OSCILLOSCPOE_REPEATER = 0x93, TIMER_PERIOD_MILLI = 250 };

typedef nx_struct oscilloscope {
  nx_uint16_t version;
  nx_uint16_t interval;
  nx_uint16_t id;
  nx_uint16_t count;
  nx_uint16_t readings[10];
}
oscilloscope_t;

#endif
