#include <Timer.h>

#include "TpsnSenderC.h"
#include "printf.h"

// Configuration
configuration TpsnSenderAppC {}

// Implementation
implementation {
  components MainC;
  components LedsC;
  components TpsnSenderC as App;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components new AMSenderC(AM_TPSNSENDER);
  components new AMReceiverC(AM_TPSNSENDER);

  App.Boot->MainC;
  App.Leds->LedsC;
  App.Timer0->Timer0;
  App.Packet->AMSenderC;
  App.AMPacket->AMSenderC;
  App.AMControl->ActiveMessageC;
  App.AMSend->AMSenderC;
  App.Receive->AMReceiverC;
}
