#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <theora/theoradec.h>

/* Helper; just grab some more compressed bitstream and sync it for
   page extraction */
int buffer_data(FILE *in, ogg_sync_state *oy) {
  char *buffer=ogg_sync_buffer(oy,4096);
  int bytes=fread(buffer,1,4096,in);
  ogg_sync_wrote(oy,bytes);
  return(bytes);
}

/* dump the theora comment header */
static int dump_comments(th_comment *tc) {
  int i, len;
  char *value;
  FILE *out=stderr;

  fprintf(out, "Encoded by %s\n", tc->vendor);
  if(tc->comments) {
    fprintf(out, "theora comment header:\n");
    for(i=0; i<tc->comments; i++) {
      if(tc->user_comments[i]) {
        len=tc->comment_lengths[i];
        value=malloc(len+1);
        memcpy(value, tc->user_comments[i], len);
        value[len]='\0';
        fprintf(out, "\t%s\n", value);
        free(value);
      }
    }
  }
  return 0;
}

/* write out the planar YUV frame, uncropped */
static void video_write(th_dec_ctx *td)
{
    int r;
    th_ycbcr_buffer ycbcr;
    if (th_decode_ycbcr_out(td, ycbcr) != 0) {
        printf("th_decode_ycbcr_out failed\n");
    }
    printf("w: %d, h: %d, stride: %d\n", ycbcr[0].width, ycbcr[0].height,
            ycbcr[0].stride);
    printf("w: %d, h: %d, stride: %d\n", ycbcr[1].width, ycbcr[1].height,
            ycbcr[1].stride);
    printf("w: %d, h: %d, stride: %d\n", ycbcr[2].width, ycbcr[2].height,
            ycbcr[2].stride);

/*
  int i;
  if(outfile){
    if(!raw)
      fprintf(outfile, "FRAME\n");
    for(i=0;i<yuv.y_height;i++)
      fwrite(yuv.y+yuv.y_stride*i, 1, yuv.y_width, outfile);
    for(i=0;i<yuv.uv_height;i++)
      fwrite(yuv.u+yuv.uv_stride*i, 1, yuv.uv_width, outfile);
    for(i=0;i<yuv.uv_height;i++)
      fwrite(yuv.v+yuv.uv_stride*i, 1, yuv.uv_width, outfile);
  }
*/
}

int main()
{
    ogg_sync_state oy;
    th_comment tc;
    th_info ti;
    ogg_page og;
    ogg_stream_state to;
    int theora_p = 0;
    int stateflag = 0;
    ogg_packet op;
    th_dec_ctx *td;
    int videobuf_ready = 0;
    ogg_int64_t videobuf_granulepos = -1;
    double videobuf_time=0;
    int frames=0;

    th_setup_info *setup=NULL;

    FILE *infile = fopen("video.ogv", "rb");
    if (infile == NULL) {
        fprintf(stderr, "Unable to open the file");
        return 1;
    }

    ogg_sync_init(&oy);
    th_comment_init(&tc);
    th_info_init(&ti);
    while (!stateflag) {
        int ret = buffer_data(infile, &oy);
        if (ret == 0) {
            printf("done");
            return 0;
        }
        while (ogg_sync_pageout(&oy, &og) > 0) {
            ogg_stream_state test;
            if (!ogg_page_bos(&og)) {
                if (theora_p) ogg_stream_pagein(&to, &og);
                stateflag = 1;
                break;
            }
            ogg_stream_init(&test, ogg_page_serialno(&og));
            ogg_stream_pagein(&test, &og);
            ogg_stream_packetout(&test, &op);
            if (!theora_p && th_decode_headerin(&ti, &tc, &setup, &op) >= 0) {
                memcpy(&to, &test, sizeof(test));
                theora_p = 1;
            } else {
                ogg_stream_clear(&test);
            }
        }
    }
    while (theora_p && theora_p < 3) {
        int ret;
        while (theora_p && (theora_p < 3) &&
                (ret=ogg_stream_packetout(&to,&op))) {
            if (ret < 0) {
                fprintf(stderr, "Error parsing headers 1");
                return 1;
            }
            if (th_decode_headerin(&ti, &tc, &setup, &op) < 0) {
                fprintf(stderr, "Error parsing headers 2");
                return 1;
            }
            theora_p++;
            if (theora_p == 3) break;
        }
        if (ogg_sync_pageout(&oy, &og) > 0) {
            if (theora_p) ogg_stream_pagein(&to, &og);
        } else {
            int ret = buffer_data(infile, &oy);
            if (ret == 0) {
                fprintf(stderr, "End of file while searching for headers");
                return 1;
            }
        }
    }
    dump_comments(&tc);
    fprintf(stderr,"Ogg logical stream %lx is Theora %dx%d %.02f fps video\n"
        "Encoded frame content is %dx%d with %dx%d offset\n"
        "Aspect: %d:%d\n",
        to.serialno, ti.pic_width, ti.pic_height,
        (double)ti.fps_numerator/ti.fps_denominator,
        ti.frame_width, ti.frame_height, ti.pic_x, ti.pic_y,
        ti.aspect_numerator, ti.aspect_denominator);

    td = th_decode_alloc(&ti, setup);
    stateflag = 0;
    while (ogg_sync_pageout(&oy, &og) > 0)
        ogg_stream_pagein(&to, &og);
    while (1) {
        while (!videobuf_ready) {
            if (ogg_stream_packetout(&to, &op) > 0) {
                th_decode_packetin(td, &op, &videobuf_granulepos);
                videobuf_time = th_granule_time(td, videobuf_granulepos);
                videobuf_ready = 1;
                frames++;
            } else
                break;
        }
        printf("\rframe:%d", frames);
        if (!videobuf_ready && feof(infile)) break;
        if (!videobuf_ready) {
            buffer_data(infile, &oy);
            while (ogg_sync_pageout(&oy, &og) > 0)
                ogg_stream_pagein(&to, &og);
        } else {
            video_write(td);
        }
        videobuf_ready = 0;
    }
    ogg_stream_clear(&to);
    th_decode_free(td);
    th_comment_clear(&tc);
    th_info_clear(&ti);
    ogg_sync_clear(&oy);
    fclose(infile);

    return 0;
}
