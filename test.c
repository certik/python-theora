#include <stdio.h>
#include <theora/theoradec.h>

/* Helper; just grab some more compressed bitstream and sync it for
   page extraction */
int buffer_data(FILE *in, ogg_sync_state *oy) {
  char *buffer=ogg_sync_buffer(oy,4096);
  int bytes=fread(buffer,1,4096,in);
  ogg_sync_wrote(oy,bytes);
  return(bytes);
}

int main()
{
    th_info info;
    th_comment tc;
    th_setup_info *setup;
    ogg_packet op;
    th_info_init(&info);
    //th_decode_headerin(&info, &tc, &setup, &op);
    return 0;
}
