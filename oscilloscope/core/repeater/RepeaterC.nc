#include "RepeaterC.h"
#include "printf.h"
#include <Timer.h>

//缓存节点1和2的数据，因为两个节点并行运行，所以必须为两个节点的数据各创一个缓存区，否则可能会覆盖发生错误
uint16_t version1, version2;
uint16_t interval1, interval2;
uint16_t id1, id2;
uint16_t count1, count2;
uint16_t readings1[10], readings2[10];

uint16_t sensor1 = 63; //用于判断收到的数据是否为节点1
uint16_t sensor2 = 64; //用于判断收到的数据是否为节点2
// uint16_t zj = 62; //用于观察是否为中继站转发而不是节点直接发而受到的信息
uint16_t s1 = 0; //用于判断是否收到节点1的数据
uint16_t s2 = 0; //用于判断是否收到节点2的数据
uint16_t i = 0;

module RepeaterC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Timer<TMilli> as Timer1;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
}

implementation {
  message_t pkt;
  bool busy = FALSE;

  void setLeds(uint16_t l) {
    if (l == 1) //收到数据改变LED0的状态
    {
      call Leds.led0Toggle();
    }
    if (l == 2) //发出节点1的数据改变LED1的状态
    {
      call Leds.led1Toggle();
    }
    if (l == 3) //发出节点2的数据改变LED2的状态
    {
      call Leds.led2Toggle();
    }
  }

  event void Boot.booted() {
    call AMControl.start();
    call Timer0.startPeriodic(250);
    call Timer1.startPeriodic(250);
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
      call Timer1.startPeriodic(TIMER_PERIOD_MILLI);
    } else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {}
  event void Timer0.fired() //周期性发送节点1的数据
  {
    if (!busy) {
      if (s1 == 1) //判断是否收到节点1的数据
      {
        oscilloscope_t *btrpkt = (oscilloscope_t *)(call Packet.getPayload(
            &pkt, sizeof(oscilloscope_t)));
        if (btrpkt == NULL) {
          return;
        }
        btrpkt->version = version1;
        btrpkt->interval = interval1;
        btrpkt->id = id1;
        btrpkt->count = count1;
        for (i = 0; i < 10; i++) {
          btrpkt->readings[i] = readings1[i];
        }
        if (call AMSend.send(61, &pkt, sizeof(oscilloscope_t)) == SUCCESS) {
          busy = TRUE;
        }
        s1 = 0;     //收到并发出以后再次置0
        setLeds(2); //改变LED的状态
      }
    }
  }

  event void Timer1.fired() //周期性发送节点2的数据
  {
    if (!busy) {
      if (s2 == 1) //判断是否收到节点1的数据
      {
        oscilloscope_t *btrpkt = (oscilloscope_t *)(call Packet.getPayload(
            &pkt, sizeof(oscilloscope_t)));
        if (btrpkt == NULL) {
          return;
        }
        btrpkt->version = version2;
        btrpkt->interval = interval2;
        btrpkt->id = id2;
        btrpkt->count = count2;
        for (i = 0; i < 10; i++) {
          btrpkt->readings[i] = readings2[i];
        }
        if (call AMSend.send(61, &pkt, sizeof(oscilloscope_t)) == SUCCESS) {
          busy = TRUE;
        }
        s2 = 0;
        setLeds(3); //改变LED的状态
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
    if (len == sizeof(oscilloscope_t)) {
      oscilloscope_t *btrpkt = (oscilloscope_t *)payload;
      if (btrpkt->id == sensor1) //若收到信息为节点1
      {
        version1 = btrpkt->version;
        interval1 = btrpkt->interval;
        id1 = btrpkt->id;
        count1 = btrpkt->count;
        for (i = 0; i < 10; i++) {
          readings1[i] = btrpkt->readings[i];
        }
        s1 = 1;
        setLeds(
            1); //只有收到节点1，2的时候才改变灯1，收到其他节点广播信息无影响
      }
      if (btrpkt->id == sensor2) //若收到信息为节点2
      {
        version2 = btrpkt->version;
        interval2 = btrpkt->interval;
        id2 = btrpkt->id;
        count2 = btrpkt->count;
        for (i = 0; i < 10; i++) {
          readings2[i] = btrpkt->readings[i];
        }
        s2 = 1;
        setLeds(1);
      }
    }
    return msg;
  }
}
