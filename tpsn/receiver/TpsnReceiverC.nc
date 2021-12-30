#include "TpsnReceiverC.h"
#include "printf.h"
#include <Timer.h>

// Module Declaration
module TpsnReceiverC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
}

// Implementation
implementation {
  uint16_t counter;
  nx_uint32_t T2;
  nx_uint32_t T3;
  message_t pkt;
  bool busy = FALSE;

  event void Boot.booted() {
    call Leds.led0Toggle();
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    } else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {}

  event void Timer0.fired() {}

  event void AMSend.sendDone(message_t * msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  event message_t *Receive.receive(message_t * msg, void *payload,
                                   uint8_t len) {
    T2 = call Timer0.getNow();
    if (len == sizeof(TpsnReceiverMsg)) {
      TpsnReceiverMsg *btrpkt = (TpsnReceiverMsg *)(call Packet.getPayload(
          &pkt, sizeof(TpsnReceiverMsg)));
      T3 = call Timer0.getNow();
      printf("T3 is: %u\n", T3); //打印T3
      printf("\n");
      printfflush();
      btrpkt->T2 = T2; //将T2和T3存入数据包
      btrpkt->T3 = T3;
      if (call AMSend.send(61, &pkt, sizeof(TpsnReceiverMsg)) == SUCCESS) {
        busy = TRUE;
      }
      call Leds.led0Toggle();
      call Leds.led1Toggle();
      call Leds.led2Toggle();
    }
    return msg;
  }
}
