// ============================================================================
// 6502 BREADBOARD COMPUTER DEBUGGER - Arduino Sketch
// ============================================================================
// This Arduino sketch monitors the 6502 breadboard computer's bus activity
// in real-time. It connects to the 6502's address and data lines to display
// every bus transaction, making it easier to debug programs and understand
// how the processor executes instructions.
//
// Hardware connections:
// - 16 address lines (A0-A15) connected to Arduino digital pins 22-52 (even)
// - 8 data lines (D0-D7) connected to Arduino digital pins 39-53 (odd)
// - Clock line connected to Arduino pin 2 (interrupt)
// - Read/Write line connected to Arduino pin 3
//
// Based on Ben Eater's 6502 tutorial series: https://eater.net/6502
// ============================================================================

// Pin assignments for 16-bit address bus (A0-A15)
const char ADDR[] = { 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52 };

// Pin assignments for 8-bit data bus (D0-D7)
const char DATA[] = { 39, 41, 43, 45, 47, 49, 51, 53 };

// Control signal pins
#define CLOCK 2         // Clock signal (connected to interrupt pin)
#define READ_WRITE 3    // Read/Write signal (high = read, low = write)

// ──────────────────────────────────────────────
// setup: Initialize Arduino pins and serial communication
// ──────────────────────────────────────────────
void setup() {
  // Configure address bus pins as inputs
  for (int n = 0; n < 16; n += 1) {
    pinMode(ADDR[n], INPUT);
  }

  // Configure data bus pins as inputs
  for (int n = 0; n < 8; n += 1) {
    pinMode(DATA[n], INPUT);
  }

  // Configure control signal pins as inputs
  pinMode(CLOCK, INPUT);
  pinMode(READ_WRITE, INPUT);

  // Attach interrupt to clock signal - triggers on rising edge
  // This means we capture bus activity on each clock cycle
  attachInterrupt(digitalPinToInterrupt(CLOCK), onClock, RISING);

  // Initialize serial communication at 57600 baud
  // This matches the baud rate expected by the monitoring software
  Serial.begin(57600);
}

// ──────────────────────────────────────────────
// onClock: Interrupt handler - called on each clock cycle
// Reads and displays the current state of address and data buses
// ──────────────────────────────────────────────
void onClock() {
  // Read 16-bit address from address bus pins
  unsigned int address = 0;
  for (int n = 0; n < 16; n += 1) {
    int bit = digitalRead(ADDR[n]) ? 1 : 0;  // Read pin state
    Serial.print(bit);                       // Print bit for debugging
    address = (address << 1) + bit;          // Build address value
  }

  Serial.print("    ");  // Separator between address and data

  // Read 8-bit data from data bus pins
  unsigned int data = 0;
  for (int n = 0; n < 8; n += 1) {
    int bit = digitalRead(DATA[n]) ? 1 : 0;  // Read pin state
    Serial.print(bit);                       // Print bit for debugging
    data = (data << 1) + bit;                // Build data value
  }

  // Format and print the bus transaction
  // Format: "address r/w data" (e.g., "8000 r A9" means read $A9 from $8000)
  char output[15];
  sprintf(output, "    %04x %c %02x", 
          address, 
          digitalRead(READ_WRITE) ? 'r' : 'w',  // 'r' for read, 'w' for write
          data);

  Serial.print(output);
  Serial.println();  // End line for this bus transaction
}

// ──────────────────────────────────────────────
// loop: Main program loop (empty - all work done in interrupt)
// ──────────────────────────────────────────────
void loop() {
  // Empty - all monitoring is done in the onClock interrupt handler
}
