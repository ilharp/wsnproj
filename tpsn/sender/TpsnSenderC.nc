#include <Timer.h>

#include "TpsnSenderC.h"
#include "printf.h"

// Module Declaration
module TpsnSenderC {
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
  nx_uint32_t T0, T1, T2, T3, T4;
  uint64_t T14, T23;
  uint32_t origin_delta, delta;

  uint32_t delay;
  message_t pkt;
  bool busy = FALSE;

  event void Boot.booted() {
    call Leds.led0Toggle();
    call AMControl.start(); //启动串口
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    } else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {}

  event void Timer0.fired() {
    atomic T0 = call Timer0.getNow(); //获取T1
    atomic T1 = T0 + (unsigned int) delta;

    counter++;

    if (!busy) {
      TpsnSenderMsg *btrpkt = (TpsnSenderMsg *)(call Packet.getPayload(
          &pkt, sizeof(TpsnSenderMsg)));
      if (btrpkt == NULL) {
        return;
      }
      btrpkt->nodeid = TOS_NODE_ID; //发送节点的ID，TOS_NODE_ID为在make telosb
                                    //install，1时设置的
      btrpkt->counter = counter;

      btrpkt->T1 = T1; //将T1存入数据包

      if (call AMSend.send(
              62, // AM_BROADCAST_ADDR广播模式,修改AM_BROADCAST_ADDR为2，则节点只向2号节点发，其他节点不响应
              &pkt, sizeof(TpsnSenderMsg)) == SUCCESS) {
        busy = TRUE;
      }
    }
  }

  event void AMSend.sendDone(message_t * msg, error_t err) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  event message_t *Receive.receive(message_t * msg, void *payload,
                                   uint8_t len) {
    atomic T4 = call Timer0.getNow();
    atomic T4 += (unsigned int) delta;
    if (len == sizeof(TpsnSenderMsg)) {
      TpsnSenderMsg *btrpkt = (TpsnSenderMsg *)payload; //提取数据包
      T2 = btrpkt->T2; //节点A从B发送回的包中提取T2和T3
      T3 = btrpkt->T3;
      T23 = T2 + T3;
      T14 = T1 + T4;
      atomic origin_delta = delta;
      if (T23 > T14) { //计算时偏
        atomic delta += ((T2 + T3) - (T1 + T4)) / 2;
      } else {
        atomic delta += ((T1 + T4) - (T2 + T3)) / 2;
      }

      atomic delay = ((T2 - T1) + (T4 - T3)) / 2; //计算时延

      printf("T1 is: %u\n",  T1);
      printf("T2 is: %u\n", T2);
      printf("T3 is: %u\n", T3);
      printf("T4 is: %u\n", T4);
      printf("delay is: %u\n", delay);
      printf("delta is: %u\n", delta);
      printf("Delta by delta: %d\n", delta - origin_delta);
      printf("\n");
      printfflush();
      call Leds.led0Toggle();
      call Leds.led1Toggle();
      call Leds.led2Toggle();
    }
    return msg;
  }
}
