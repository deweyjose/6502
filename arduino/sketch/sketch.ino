const char ADDR[] = { 52, 50, 48, 46, 44, 42, 40, 38, 36, 34, 32, 30, 28, 26, 24, 22 };
const char DATA[] = { 53, 51, 49, 47, 45, 43, 41, 39 };


#define CLOCK 2
#define READ_WRITE 3

void setup() {
  for (int n = 0; n < 16; n += 1) {
    pinMode(ADDR[n], INPUT);
  }

  for (int n = 0; n < 8; n += 1) {
    pinMode(DATA[n], INPUT);
  }

  pinMode(CLOCK, INPUT);
  pinMode(READ_WRITE, INPUT);

  attachInterrupt(digitalPinToInterrupt(CLOCK), onClock, RISING);

  Serial.begin(57600);
}



void onClock() {
  unsigned int address = 0;
  for (int n = 0; n < 16; n += 1) {
    int bit = digitalRead(ADDR[n]) ? 1 : 0;
    Serial.print(bit);
    address = (address << 1) + bit;
  }

  Serial.print("    ");

  unsigned int data = 0;
  for (int n = 0; n < 8; n += 1) {
    int bit = digitalRead(DATA[n]) ? 1 : 0;
    Serial.print(bit);
    data = (data << 1) + bit;
  }

  char output[15];
  sprintf(output, "    %04x %c %02x", address, digitalRead(READ_WRITE) ? 'r' : 'w', data);

  Serial.print(output);

  Serial.println();
}

void loop() {}
