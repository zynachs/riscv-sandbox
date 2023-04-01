#include "../include/altio.h"
#include "../include/aes128.h"

#define BUFSIZE 8192

// MAC key
uint32_t mac_key[4] = {
    0x0f8955f2,
    0xebc5973a,
    0x546c28e2,
    0xe111547d,
};

// MAC round keys
uint32_t mac_rk[44];

// Message buffer
uint8_t buf[BUFSIZE];

// MAC buffer
uint8_t mac[16];

// Message string
static char msg[] = {0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f,0x00};
//static uint8_t msg[] = "Is this a valide string?";
uint64_t len = 0;

void setup() {
	alt_puts("This is setup!");

	// Move msg to buf
	for (int i = 0; msg[i] != '\0' ; i++) {
		buf[i] = msg[i];
		len += 1;
	}

	// Create round-key from key
	aes128_keyexpansion(mac_key, mac_rk);

	return;
}

void loop () {
	alt_puts("This is loop!");

	// Print msg
	alt_printf("msg plain: \n%s\n\n", msg[0] >= 0x20 && msg[0] < 0x7F ? msg : "not plaintext");
	alt_printf("msg hex: \n");
	for (int i = 0; i <= len; i++) {
		alt_printf("%X ", msg[i]);
		if (i != 0 && i % 15 == 0) {
			alt_puts("");
		}
	}
	alt_puts("");
	alt_puts("");

	// Compute hash of msg and store in mac
	aes128_cbc_mac(mac_rk, buf, mac, len);
	
	// Print mac
	alt_printf("mac hex: \n");
	for (int i = 0; i < 16; i++) {
		alt_printf("%x ", mac[i]);
	}
	alt_puts("");
	alt_puts("");

	return;
}
