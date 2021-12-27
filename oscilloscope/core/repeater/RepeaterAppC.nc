#include "RepeaterC.h"
#include <Timer.h>

configuration RepeaterAppC {}

implementation {
  components MainC;
  components LedsC;
  components RepeaterC;
  components new TimerMilliC() as Timer0;
  components new TimerMilliC() as Timer1;
  components ActiveMessageC;
  components new AMSenderC(AM_OSCILLOSCPOE_REPEATER);
  components new AMReceiverC(AM_OSCILLOSCPOE_REPEATER);

  RepeaterC.Boot->MainC;
  RepeaterC.Leds->LedsC;
  RepeaterC.Timer0->Timer0;
  RepeaterC.Timer1->Timer1;
  RepeaterC.Packet->AMSenderC;
  RepeaterC.AMPacket->AMSenderC;
  RepeaterC.AMControl->ActiveMessageC;
  RepeaterC.AMSend->AMSenderC;
  RepeaterC.Receive->AMReceiverC;
}
