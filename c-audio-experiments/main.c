#define FRAME_SIZE 236300
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

int main(){

    // Import wave file converted to raw to a 16bit array
    FILE *fin, *foutShort, *foutFloat;
    fin = fopen("sample.raw", "r");
    foutShort = fopen("processedShort.raw", "w");
    foutFloat = fopen("processedFloat.raw", "w");
    short shortRaw[FRAME_SIZE];
    float floatRaw[FRAME_SIZE];
    fread(shortRaw, sizeof(short), FRAME_SIZE, fin);

    // Copy to 32 bit array
    for(int i=0; i < FRAME_SIZE; i++){
        floatRaw[i] = shortRaw[i];
    }
    
    // Dump both to raw files
    fwrite(shortRaw, sizeof(short), FRAME_SIZE, foutShort);
    fwrite(floatRaw, sizeof(float), FRAME_SIZE, foutFloat);

    return 0;
}

/*
    Pre-processing:
    1. Converted to raw: sox sample.wav sample.raw
    2. Opened raw with audacity 16bit signed mono 48khz little endian
    
    3. Compile: gcc main.c -o experiment
    4. Processing: ./experiment

    Post Processing:
    5. Opening processedShort.raw with previously mentioned settings in audacity yields desired results
    6. Opening processedFloat.raw with previously mentioned settings in audacity yields desired results
    but has some trailing garbage after the full length of the useful file has been played. To trim them
    out just use: 
    
    sox -t raw -r 48000 -b 16 -e signed-integer -c 1 processedFloat.raw processedFloat.wav

    to convert the file to wav and then to trim it use:

    sox processedFloat.wav processedFloatTrimmed.wav trim 0 4.92
    
    (keeps file from 0s to 4.92s)

*/