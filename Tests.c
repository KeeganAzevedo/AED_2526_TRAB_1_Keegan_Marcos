#include "imageRGB.h"

int main(){
    //create image

    Image myImage;

    ImageCreate(16,16);

    
    printf(ImageColors(myImage));
    printf(ImageColors(myImage));
    return 0;
}