#include <theora/theoradec.h>

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
