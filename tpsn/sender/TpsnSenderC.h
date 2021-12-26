#ifndef TPSN_SENDER_H
#define TPSN_SENDER_H

enum { AM_TPSNSENDER = 6, TIMER_PERIOD_MILLI = 3000 };

typedef nx_struct TpsnSenderMsg {
  nx_uint16_t nodeid;
  nx_uint16_t counter;
  nx_uint32_t T1;
  nx_uint32_t T2;
  nx_uint32_t T3;
}
TpsnSenderMsg;

#endif
