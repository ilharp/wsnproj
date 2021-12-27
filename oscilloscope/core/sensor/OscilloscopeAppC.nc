configuration OscilloscopeAppC {}

implementation {
  components OscilloscopeC, MainC, ActiveMessageC, LedsC, new TimerMilliC(),
      new DemoSensorC() as Sensor, new AMSenderC(AM_OSCILLOSCOPE),
      new AMReceiverC(AM_OSCILLOSCOPE);

  OscilloscopeC.Boot->MainC;
  OscilloscopeC.RadioControl->ActiveMessageC;
  OscilloscopeC.AMSend->AMSenderC;
  OscilloscopeC.Receive->AMReceiverC;
  OscilloscopeC.Timer->TimerMilliC;
  OscilloscopeC.Read->Sensor;
  OscilloscopeC.Leds->LedsC;
}
