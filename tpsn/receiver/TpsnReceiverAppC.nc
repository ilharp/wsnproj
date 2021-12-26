#include "TpsnReceiverC.h"
#include "printf.h"
#include <Timer.h>

// Configuration
configuration TpsnReceiverAppC {}

// Implementation
implementation {
  components MainC;
  components LedsC;
  components TpsnReceiverC as App;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components new AMSenderC(AM_TPSNRECEIVER);
  components new AMReceiverC(AM_TPSNRECEIVER);

  App.Boot->MainC;
  App.Leds->LedsC;
  App.Timer0->Timer0;
  App.Packet->AMSenderC;
  App.AMPacket->AMSenderC;
  App.AMControl->ActiveMessageC;
  App.AMSend->AMSenderC;
  App.Receive->AMReceiverC;
}
