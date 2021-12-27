configuration BaseStationAppC {}

implementation {
  components MainC, BaseStationC, LedsC;
  components ActiveMessageC as Radio, SerialActiveMessageC as Serial;

  MainC.Boot <- BaseStationC;

  BaseStationC.RadioControl->Radio;
  BaseStationC.SerialControl->Serial;

  BaseStationC.UartSend->Serial;
  BaseStationC.UartReceive->Serial.Receive;
  BaseStationC.UartPacket->Serial;
  BaseStationC.UartAMPacket->Serial;

  BaseStationC.RadioSend->Radio;
  BaseStationC.RadioReceive->Radio.Receive;
  BaseStationC.RadioSnoop->Radio.Snoop;
  BaseStationC.RadioPacket->Radio;
  BaseStationC.RadioAMPacket->Radio;

  BaseStationC.Leds->LedsC;
}
